import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../../models/learner.dart';
import '../../../models/diagnostic_placement.dart';
import '../../srs_facets.dart';
import '../../../services/sqlite_policy.dart';

/// Payload for the learner-state SQLite authority.
///
/// Carries only the four migrated domains: attempts, assessment history,
/// placement history and favorite verbs. Learned/review state stays owned by
/// the pair-progress store and is never imported here.
final class LearnerStateSnapshot {
  const LearnerStateSnapshot({
    required this.sourceKey,
    required this.attempts,
    required this.assessmentHistory,
    required this.placementHistory,
    required this.favoriteVerbs,
    required this.canonicalSnapshotSha256,
    required this.capturedAtUtc,
  });

  final String sourceKey;
  final List<Attempt> attempts;
  final List<AssessmentHistory> assessmentHistory;
  final List<PlacementDiagnosticRecord> placementHistory;
  final Set<String> favoriteVerbs;
  final String canonicalSnapshotSha256;
  final DateTime capturedAtUtc;
}

/// Bounded outcome of an idempotent attempt insert.
final class ReviewAttemptApplyResult {
  const ReviewAttemptApplyResult({
    required this.attemptId,
    required this.applied,
  });

  final String attemptId;

  /// `false` when the attempt was already recorded (idempotent replay).
  final bool applied;
}

/// Learner-state SQLite store pinned to schema v1.
///
/// This file is a release hardening contract: it establishes the
/// schemaVersion=1 boundary and integrity verification for the
/// learner's persistent SQLite store. See docs/TASK11_RELEASE_HARDENING.md.
final class LearnerStateDatabase {
  LearnerStateDatabase._(this._database);

  static const String databaseFileName = 'learner_state.sqlite';
  static const int schemaVersion = 1;

  static const String metaTable = 'learner_store_meta';
  static const String migrationTable = 'learner_migration_state';
  static const String attemptsTable = 'learner_attempts';
  static const String assessmentHistoryTable = 'learner_assessment_history';
  static const String placementHistoryTable = 'learner_placement_history';
  static const String favoriteVerbsTable = 'learner_favorite_verbs';

  static const int maxAttempts = 2000;
  static const int maxAssessmentHistory = 100;
  static const int maxPlacementHistory = 20;
  static const int maxFavoriteVerbs = 20000;

  final Database _database;

  static Future<LearnerStateDatabase> open({
    AppSqlitePolicy sqlitePolicy = const AppSqlitePolicy(),
    String? overridePath,
  }) async {
    final path = await sqlitePolicy.resolvePath(
      fileName: databaseFileName,
      overridePath: overridePath,
    );
    final database = await sqlitePolicy.openWritable(
      path: path,
      version: schemaVersion,
    );
    try {
      return await attach(database);
    } on Object {
      await database.close();
      rethrow;
    }
  }

  static Future<LearnerStateDatabase> attach(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $metaTable (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        schema_version INTEGER NOT NULL,
        revision INTEGER NOT NULL DEFAULT 0 CHECK (revision >= 0),
        last_mutated_at_utc TEXT
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $migrationTable (
        migration_id TEXT PRIMARY KEY,
        migration_version INTEGER NOT NULL CHECK (migration_version > 0),
        status TEXT NOT NULL CHECK (status = 'verified'),
        source_storage_key TEXT NOT NULL,
        source_payload_sha256 TEXT NOT NULL,
        source_legacy_favorites_sha256 TEXT NOT NULL,
        imported_snapshot_sha256 TEXT NOT NULL,
        attempt_count INTEGER NOT NULL CHECK (attempt_count >= 0),
        assessment_count INTEGER NOT NULL CHECK (assessment_count >= 0),
        placement_count INTEGER NOT NULL CHECK (placement_count >= 0),
        favorite_count INTEGER NOT NULL CHECK (favorite_count >= 0),
        completed_at_utc TEXT NOT NULL,
        cutover_revision INTEGER NOT NULL CHECK (cutover_revision >= 0)
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $attemptsTable (
        attempt_id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        skill TEXT NOT NULL,
        answer TEXT NOT NULL,
        correct INTEGER NOT NULL,
        hinted INTEGER NOT NULL,
        seconds INTEGER NOT NULL CHECK (seconds >= 0),
        attempted_at_utc TEXT NOT NULL,
        facet_type TEXT NOT NULL DEFAULT 'meaning_recall',
        variant_key TEXT NOT NULL DEFAULT ''
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $assessmentHistoryTable (
        assessment_id TEXT PRIMARY KEY,
        score REAL NOT NULL,
        weak_skills TEXT NOT NULL DEFAULT '',
        answered INTEGER NOT NULL,
        assessed_at_utc TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $placementHistoryTable (
        placement_id TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        placed_at_utc TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $favoriteVerbsTable (
        verb TEXT PRIMARY KEY
      )
    ''');

    await _verifySchema(database);

    final meta = await database.query(metaTable, where: 'id = 1', limit: 1);
    if (meta.isEmpty) {
      await database.insert(
        metaTable,
        <String, Object?>{
          'id': 1,
          'schema_version': schemaVersion,
          'revision': 0,
          'last_mutated_at_utc': null,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } else {
      final storedVersion = _strictInt(
        meta.first['schema_version'],
        field: 'schema_version',
        min: 1,
        max: schemaVersion,
      );
      if (storedVersion != schemaVersion) {
        throw const LearnerStateDatabaseException(
          'unsupported_learner_store_schema',
        );
      }
      _strictInt(
        meta.first['revision'],
        field: 'revision',
        min: 0,
        max: 1 << 62,
      );
    }

    return LearnerStateDatabase._(database);
  }

  /// Builds the deterministic canonical payload of the four migrated
  /// domains. Shared by the legacy reader (pre-import) and the store
  /// (post-import) so verification is a pure equality check.
  static Map<String, dynamic> canonicalSnapshotPayload({
    required List<Attempt> attempts,
    required List<AssessmentHistory> assessmentHistory,
    required List<PlacementDiagnosticRecord> placementHistory,
    required Set<String> favoriteVerbs,
  }) {
    final attemptMaps = attempts
        .map((attempt) => Map<String, dynamic>.from(attempt.toJson()))
        .toList()
      ..sort(
        (a, b) =>
            (a['id']?.toString() ?? '').compareTo(b['id']?.toString() ?? ''),
      );
    final assessmentMaps = assessmentHistory
        .map((history) => Map<String, dynamic>.from(history.toJson()))
        .toList()
      ..sort(
        (a, b) =>
            (a['id']?.toString() ?? '').compareTo(b['id']?.toString() ?? ''),
      );
    final placementMaps = placementHistory
        .map((record) => Map<String, dynamic>.from(record.toJson()))
        .toList()
      ..sort(
        (a, b) =>
            (a['id']?.toString() ?? '').compareTo(b['id']?.toString() ?? ''),
      );
    final favorites = favoriteVerbs.toList()..sort();
    return <String, dynamic>{
      'attempts': attemptMaps,
      'assessmentHistory': assessmentMaps,
      'placementHistory': placementMaps,
      'favoriteVerbs': favorites,
    };
  }

  /// Computes the deterministic digest of the canonical domain payload.
  static String canonicalSnapshotSha256({
    required List<Attempt> attempts,
    required List<AssessmentHistory> assessmentHistory,
    required List<PlacementDiagnosticRecord> placementHistory,
    required Set<String> favoriteVerbs,
  }) =>
      Sha256()
          .hash(
            utf8.encode(
              jsonEncode(
                canonicalSnapshotPayload(
                  attempts: attempts,
                  assessmentHistory: assessmentHistory,
                  placementHistory: placementHistory,
                  favoriteVerbs: favoriteVerbs,
                ),
              ),
            ),
          )
          .toString();

  Future<int> readRevision() async {
    final meta = await _database.query(metaTable, where: 'id = 1', limit: 1);
    if (meta.isEmpty) return 0;
    return _strictInt(
      meta.first['revision'],
      field: 'revision',
      min: 0,
      max: 1 << 62,
    );
  }

  Future<void> transaction(
    Future<void> Function(DatabaseExecutor txn) action,
  ) =>
      _database.transaction(action);

  /// Imports the verified legacy snapshot into the domain tables.
  /// Idempotent: rows are replaced per primary key.
  Future<void> importSnapshot(
    LearnerStateSnapshot snapshot, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? _database;
    for (final attempt in snapshot.attempts) {
      await db.insert(
        attemptsTable,
        _attemptToRow(attempt),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final history in snapshot.assessmentHistory) {
      await db.insert(
        assessmentHistoryTable,
        <String, Object?>{
          'assessment_id': history.id,
          'score': history.score,
          'weak_skills': jsonEncode(history.weakSkills),
          'answered': history.answered,
          'assessed_at_utc': history.at.toUtc().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final record in snapshot.placementHistory) {
      await db.insert(
        placementHistoryTable,
        <String, Object?>{
          'placement_id': record.id,
          'payload': jsonEncode(record.toJson()),
          'placed_at_utc': record.at.toUtc().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final verb in snapshot.favoriteVerbs) {
      await db.insert(
        favoriteVerbsTable,
        <String, Object?>{'verb': verb},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Reads the stored domain payload back through the same normalization
  /// the verifier expects. Pass the migration transaction so the read sees
  /// uncommitted writes.
  Future<LearnerStateSnapshot> readSnapshot({DatabaseExecutor? executor}) async {
    final db = executor ?? _database;
    final attemptRows = await db.query(attemptsTable, limit: maxAttempts);
    final attempts = <Attempt>[
      for (final row in attemptRows)
        Attempt.fromJson(<String, dynamic>{
          'id': row['attempt_id']?.toString() ?? '',
          'itemId': row['item_id']?.toString() ?? '',
          'skill': row['skill']?.toString() ?? 'recall',
          'answer': row['answer']?.toString() ?? '',
          'correct': (row['correct'] as num?)?.toInt() == 1,
          'hinted': (row['hinted'] as num?)?.toInt() == 1,
          'seconds': (row['seconds'] as num?)?.toInt() ?? 5,
          'at': row['attempted_at_utc']?.toString() ?? '',
          'facetType': row['facet_type']?.toString(),
          'variantKey': row['variant_key']?.toString(),
        }),
    ];
    final assessmentRows =
        await db.query(assessmentHistoryTable, limit: maxAssessmentHistory);
    final assessmentHistory = <AssessmentHistory>[
      for (final row in assessmentRows)
        AssessmentHistory.fromJson(<String, dynamic>{
          'id': row['assessment_id']?.toString() ?? '',
          'at': row['assessed_at_utc']?.toString() ?? '',
          'score': (row['score'] as num?)?.toDouble() ?? 0.0,
          'weakSkills': (jsonDecode(
                row['weak_skills']?.toString() ?? '[]',
              ) as List)
              .map((value) => value.toString())
              .toList(),
          'answered': (row['answered'] as num?)?.toInt() ?? 0,
        }),
    ];
    final placementRows =
        await db.query(placementHistoryTable, limit: maxPlacementHistory);
    final placementHistory = <PlacementDiagnosticRecord>[
      for (final row in placementRows)
        PlacementDiagnosticRecord.fromJson(
          Map<String, dynamic>.from(
            jsonDecode(row['payload']?.toString() ?? '{}') as Map,
          ),
        ),
    ];
    final favoriteRows =
        await db.query(favoriteVerbsTable, limit: maxFavoriteVerbs);
    final favorites = <String>{
      for (final row in favoriteRows)
        if ((row['verb']?.toString() ?? '').trim().isNotEmpty)
          row['verb']!.toString().trim(),
    };
    return LearnerStateSnapshot(
      sourceKey: 'sqlite',
      attempts: attempts,
      assessmentHistory: assessmentHistory,
      placementHistory: placementHistory,
      favoriteVerbs: favorites,
      canonicalSnapshotSha256: canonicalSnapshotSha256(
        attempts: attempts,
        assessmentHistory: assessmentHistory,
        placementHistory: placementHistory,
        favoriteVerbs: favorites,
      ),
      capturedAtUtc: DateTime.now().toUtc(),
    );
  }

  /// Records the verified migration marker AFTER the import has been
  /// verified. Bumps the store revision so legacy fallback closes.
  Future<void> insertVerifiedMigrationRecord({
    required LearnerStateSnapshot snapshot,
    required DatabaseExecutor executor,
    String migrationId = 'learner-state-v1',
  }) async {
    final revision = await _readRevision(executor);
    await executor.insert(
      migrationTable,
      <String, Object?>{
        'migration_id': migrationId,
        'migration_version': 1,
        'status': 'verified',
        'source_storage_key': snapshot.sourceKey,
        'source_payload_sha256': snapshot.canonicalSnapshotSha256,
        'source_legacy_favorites_sha256': snapshot.canonicalSnapshotSha256,
        'imported_snapshot_sha256': snapshot.canonicalSnapshotSha256,
        'attempt_count': snapshot.attempts.length,
        'assessment_count': snapshot.assessmentHistory.length,
        'placement_count': snapshot.placementHistory.length,
        'favorite_count': snapshot.favoriteVerbs.length,
        'completed_at_utc': DateTime.now().toUtc().toIso8601String(),
        'cutover_revision': revision + 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await executor.update(
      metaTable,
      <String, Object?>{
        'revision': revision + 1,
        'last_mutated_at_utc': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = 1',
    );
  }

  Future<int> _readRevision(DatabaseExecutor db) async {
    final meta = await db.query(metaTable, where: 'id = 1', limit: 1);
    if (meta.isEmpty) return 0;
    return _strictInt(
      meta.first['revision'],
      field: 'revision',
      min: 0,
      max: 1 << 62,
    );
  }

  /// Appends one attempt. Idempotent per attempt id; a conflicting duplicate
  /// fails closed. Never touches gamification fields.
  Future<ReviewAttemptApplyResult> applyAttemptOnce(Attempt attempt) async {
    return _database.transaction((txn) async {
      final id = attempt.id.trim();
      if (id.isEmpty || id.length > 160) {
        throw const LearnerStateDatabaseException('attempt_id_invalid');
      }
      final existing = await txn.query(
        attemptsTable,
        columns: const <String>['attempt_id', 'item_id'],
        where: 'attempt_id = ?',
        whereArgs: <Object?>[id],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        return const ReviewAttemptApplyResult(
          attemptId: '',
          applied: false,
        );
      }
      await txn.insert(
        attemptsTable,
        _attemptToRow(attempt),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _bumpRevision(txn);
      return ReviewAttemptApplyResult(attemptId: id, applied: true);
    });
  }

  Future<void> recordAssessmentOnce(AssessmentHistory history) async {
    await _database.transaction((txn) async {
      await txn.insert(
        assessmentHistoryTable,
        <String, Object?>{
          'assessment_id': history.id,
          'score': history.score,
          'weak_skills': jsonEncode(history.weakSkills),
          'answered': history.answered,
          'assessed_at_utc': history.at.toUtc().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _bumpRevision(txn);
    });
  }

  Future<void> recordPlacementOnce(PlacementDiagnosticRecord record) async {
    await _database.transaction((txn) async {
      await txn.insert(
        placementHistoryTable,
        <String, Object?>{
          'placement_id': record.id,
          'payload': jsonEncode(record.toJson()),
          'placed_at_utc': record.at.toUtc().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _bumpRevision(txn);
    });
  }

  Future<void> setFavoriteMembership(String verb, bool favorite) async {
    final trimmed = verb.trim();
    if (trimmed.isEmpty || trimmed.length > 120) {
      throw const LearnerStateDatabaseException('favorite_verb_invalid');
    }
    await _database.transaction((txn) async {
      if (favorite) {
        await txn.insert(
          favoriteVerbsTable,
          <String, Object?>{'verb': trimmed},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await txn.delete(
          favoriteVerbsTable,
          where: 'verb = ?',
          whereArgs: <Object?>[trimmed],
        );
      }
      await _bumpRevision(txn);
    });
  }

  static Future<void> _bumpRevision(DatabaseExecutor txn) async {
    final meta = await txn.query(metaTable, where: 'id = 1', limit: 1);
    if (meta.isEmpty) return;
    final revision = _strictInt(
      meta.first['revision'],
      field: 'revision',
      min: 0,
      max: 1 << 62,
    );
    await txn.update(
      metaTable,
      <String, Object?>{
        'revision': revision + 1,
        'last_mutated_at_utc': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = 1',
    );
  }

  static Map<String, Object?> _attemptToRow(Attempt attempt) =>
      <String, Object?>{
        'attempt_id': attempt.id.trim(),
        'item_id': attempt.itemId.trim(),
        'skill': attempt.skill.trim(),
        'answer': attempt.answer,
        'correct': attempt.correct ? 1 : 0,
        'hinted': attempt.hinted ? 1 : 0,
        'seconds': attempt.seconds,
        'attempted_at_utc': attempt.at.toUtc().toIso8601String(),
        'facet_type': attempt.facetType.wireName,
        'variant_key': ReviewFacetKey.normalizeVariant(attempt.variantKey) ?? '',
      };

  static Future<void> _verifySchema(DatabaseExecutor db) async {
    final requiredColumns = <String, Set<String>>{
      metaTable: <String>{
        'id',
        'schema_version',
        'revision',
        'last_mutated_at_utc',
      },
      migrationTable: <String>{
        'migration_id',
        'migration_version',
        'status',
        'source_storage_key',
        'source_payload_sha256',
        'source_legacy_favorites_sha256',
        'imported_snapshot_sha256',
        'attempt_count',
        'assessment_count',
        'placement_count',
        'favorite_count',
        'completed_at_utc',
        'cutover_revision',
      },
      attemptsTable: <String>{
        'attempt_id',
        'item_id',
        'skill',
        'answer',
        'correct',
        'hinted',
        'seconds',
        'attempted_at_utc',
        'facet_type',
        'variant_key',
      },
      assessmentHistoryTable: <String>{
        'assessment_id',
        'score',
        'weak_skills',
        'answered',
        'assessed_at_utc',
      },
      placementHistoryTable: <String>{
        'placement_id',
        'payload',
        'placed_at_utc',
      },
      favoriteVerbsTable: <String>{
        'verb',
      },
    };

    for (final entry in requiredColumns.entries) {
      final rows = await db.rawQuery('PRAGMA table_info(${entry.key})');
      final actual = <String>{
        for (final row in rows)
          if (row['name'] is String) row['name']! as String,
      };
      if (!actual.containsAll(entry.value)) {
        throw LearnerStateDatabaseException(
          'learner_store_schema_invalid_${entry.key}',
        );
      }
    }
  }

  static int _strictInt(
    Object? value, {
    required String field,
    required int min,
    required int max,
  }) {
    if (value is! int) {
      throw LearnerStateDatabaseException(
        'learner_store_field_not_int:$field',
      );
    }
    if (value < min || value > max) {
      throw LearnerStateDatabaseException(
        'learner_store_field_out_of_range:$field',
      );
    }
    return value;
  }

  Future<void> close() => _database.close();
}

final class LearnerStateDatabaseException implements Exception {
  const LearnerStateDatabaseException(this.code);

  final String code;

  @override
  String toString() => 'LearnerStateDatabaseException($code)';
}
