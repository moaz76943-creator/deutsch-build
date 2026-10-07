import 'package:sqflite_common/sqlite_api.dart';

import '../../../models/diagnostic_placement.dart';
import '../../../models/learner.dart';
import '../../srs_facets.dart';
import '../../../services/sqlite_policy.dart';

part 'learner_state_database_codec.dart';
part 'learner_state_database_models.dart';

final class LearnerStateDatabase {
  LearnerStateDatabase._(this._database);

  static const String databaseFileName = 'learner_state.sqlite';
  static const int schemaVersion = 1;

  static const String metaTable = 'learner_store_meta';
  static const String attemptsTable = 'learner_attempts';
  static const String assessmentTable = 'learner_assessment_history';
  static const String assessmentWeakSkillsTable =
      'learner_assessment_weak_skills';
  static const String placementTable = 'learner_placement_history';
  static const String placementScoresTable =
      'learner_placement_dimension_scores';
  static const String placementWeakTable =
      'learner_placement_weak_dimensions';
  static const String placementReviewItemsTable =
      'learner_placement_review_items';
  static const String favoritesTable = 'learner_favorite_verbs';
  static const String migrationTable = 'learner_migration_state';

  static const int maxAttempts = 2000;
  static const int maxAssessments = 100;
  static const int maxPlacements = 20;
  static const int maxFavorites = 20000;
  static const int maxWeakSkills = 8;
  static const int maxPlacementReviewItems = 20;
  static const int maxIdentifierLength = 160;
  static const int maxAnswerLength = 1000;

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
      CREATE TABLE IF NOT EXISTS $attemptsTable (
        attempt_id TEXT PRIMARY KEY,
        ordinal INTEGER NOT NULL UNIQUE CHECK (ordinal >= 0),
        item_id TEXT NOT NULL,
        skill TEXT NOT NULL,
        answer TEXT NOT NULL,
        correct INTEGER NOT NULL CHECK (correct IN (0, 1)),
        hinted INTEGER NOT NULL CHECK (hinted IN (0, 1)),
        seconds INTEGER NOT NULL CHECK (seconds BETWEEN 0 AND 3600),
        occurred_at_utc TEXT NOT NULL,
        facet_type TEXT NOT NULL,
        variant_key TEXT NOT NULL DEFAULT ''
      )
    ''');
    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_learner_attempts_time '
      'ON $attemptsTable(occurred_at_utc, ordinal)',
    );
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $assessmentTable (
        assessment_id TEXT PRIMARY KEY,
        ordinal INTEGER NOT NULL UNIQUE CHECK (ordinal >= 0),
        occurred_at_utc TEXT NOT NULL,
        score REAL NOT NULL CHECK (score >= 0 AND score <= 100),
        answered INTEGER NOT NULL CHECK (answered BETWEEN 0 AND 100)
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $assessmentWeakSkillsTable (
        assessment_id TEXT NOT NULL,
        position INTEGER NOT NULL CHECK (position >= 0),
        skill TEXT NOT NULL,
        PRIMARY KEY (assessment_id, position),
        FOREIGN KEY (assessment_id)
          REFERENCES $assessmentTable(assessment_id)
          ON DELETE CASCADE
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $placementTable (
        placement_id TEXT PRIMARY KEY,
        ordinal INTEGER NOT NULL UNIQUE CHECK (ordinal >= 0),
        occurred_at_utc TEXT NOT NULL,
        answered INTEGER NOT NULL CHECK (answered BETWEEN 0 AND 20),
        scored_answers INTEGER NOT NULL
          CHECK (scored_answers BETWEEN 0 AND 20),
        score REAL NOT NULL CHECK (score >= 0 AND score <= 100),
        confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
        band TEXT NOT NULL,
        curriculum_start_level TEXT,
        recommended_start_task_order INTEGER NOT NULL
          CHECK (recommended_start_task_order BETWEEN 1 AND 50),
        learning_goal TEXT
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $placementScoresTable (
        placement_id TEXT NOT NULL,
        dimension TEXT NOT NULL,
        score REAL NOT NULL CHECK (score >= 0 AND score <= 1),
        PRIMARY KEY (placement_id, dimension),
        FOREIGN KEY (placement_id)
          REFERENCES $placementTable(placement_id)
          ON DELETE CASCADE
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $placementWeakTable (
        placement_id TEXT NOT NULL,
        position INTEGER NOT NULL CHECK (position >= 0),
        dimension TEXT NOT NULL,
        PRIMARY KEY (placement_id, position),
        FOREIGN KEY (placement_id)
          REFERENCES $placementTable(placement_id)
          ON DELETE CASCADE
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $placementReviewItemsTable (
        placement_id TEXT NOT NULL,
        position INTEGER NOT NULL CHECK (position >= 0),
        item_id TEXT NOT NULL,
        PRIMARY KEY (placement_id, position),
        FOREIGN KEY (placement_id)
          REFERENCES $placementTable(placement_id)
          ON DELETE CASCADE
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $favoritesTable (
        verb TEXT PRIMARY KEY
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

  static Future<void> _verifySchema(DatabaseExecutor db) async {
    final requiredColumns = <String, Set<String>>{
      metaTable: <String>{
        'id',
        'schema_version',
        'revision',
        'last_mutated_at_utc',
      },
      attemptsTable: <String>{
        'attempt_id',
        'ordinal',
        'item_id',
        'skill',
        'answer',
        'correct',
        'hinted',
        'seconds',
        'occurred_at_utc',
        'facet_type',
        'variant_key',
      },
      assessmentTable: <String>{
        'assessment_id',
        'ordinal',
        'occurred_at_utc',
        'score',
        'answered',
      },
      assessmentWeakSkillsTable: <String>{
        'assessment_id',
        'position',
        'skill',
      },
      placementTable: <String>{
        'placement_id',
        'ordinal',
        'occurred_at_utc',
        'answered',
        'scored_answers',
        'score',
        'confidence',
        'band',
        'curriculum_start_level',
        'recommended_start_task_order',
        'learning_goal',
      },
      placementScoresTable: <String>{
        'placement_id',
        'dimension',
        'score',
      },
      placementWeakTable: <String>{
        'placement_id',
        'position',
        'dimension',
      },
      placementReviewItemsTable: <String>{
        'placement_id',
        'position',
        'item_id',
      },
      favoritesTable: <String>{'verb'},
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

  Future<T> transaction<T>(
    Future<T> Function(DatabaseExecutor txn) action,
  ) =>
      _database.transaction(action);

  Future<int> loadRevision({DatabaseExecutor? executor}) async {
    final db = executor ?? _database;
    final rows = await db.query(metaTable, where: 'id = 1', limit: 1);
    if (rows.length != 1) {
      throw const LearnerStateDatabaseException(
        'learner_store_meta_missing',
      );
    }
    return _strictInt(
      rows.first['revision'],
      field: 'revision',
      min: 0,
      max: 1 << 62,
    );
  }

  Future<bool> hasDomainRows({DatabaseExecutor? executor}) async {
    final db = executor ?? _database;
    for (final table in <String>[
      attemptsTable,
      assessmentTable,
      assessmentWeakSkillsTable,
      placementTable,
      placementScoresTable,
      placementWeakTable,
      placementReviewItemsTable,
      favoritesTable,
    ]) {
      final rows = await db.query(table, columns: const <String>['rowid'], limit: 1);
      if (rows.isNotEmpty) return true;
    }
    return false;
  }

  Future<LearnerMigrationRecord?> loadMigrationRecord(
    String migrationId, {
    DatabaseExecutor? executor,
  }) async {
    final id = _strictIdentifier(migrationId, field: 'migration_id');
    final db = executor ?? _database;
    final rows = await db.query(
      migrationTable,
      where: 'migration_id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LearnerMigrationRecord.fromRow(rows.single);
  }

  Future<LearnerSqliteSnapshot> readSnapshot({
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? _database;
    final attempts = await _readAttempts(db);
    final assessments = await _readAssessments(db);
    final placements = await _readPlacements(db);
    final favorites = await _readFavorites(db);
    return LearnerSqliteSnapshot(
      attempts: attempts,
      assessmentHistory: assessments,
      placementHistory: placements,
      favoriteVerbs: favorites,
    );
  }

  Future<void> importSnapshot(
    DatabaseExecutor txn,
    LearnerSqliteSnapshot snapshot,
  ) async {
    _validateSnapshotBounds(snapshot);

    for (var index = 0; index < snapshot.attempts.length; index += 1) {
      final attempt = _validateAttempt(snapshot.attempts[index]);
      await txn.insert(
        attemptsTable,
        <String, Object?>{
          'attempt_id': attempt.id,
          'ordinal': index,
          'item_id': attempt.itemId,
          'skill': attempt.skill,
          'answer': attempt.answer,
          'correct': attempt.correct ? 1 : 0,
          'hinted': attempt.hinted ? 1 : 0,
          'seconds': attempt.seconds,
          'occurred_at_utc': attempt.at.toUtc().toIso8601String(),
          'facet_type': attempt.facetType.wireName,
          'variant_key':
              ReviewFacetKey.normalizeVariant(attempt.variantKey) ?? '',
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }

    for (var index = 0;
        index < snapshot.assessmentHistory.length;
        index += 1) {
      final assessment =
          _validateAssessment(snapshot.assessmentHistory[index]);
      await txn.insert(
        assessmentTable,
        <String, Object?>{
          'assessment_id': assessment.id,
          'ordinal': snapshot.assessmentHistory.length - 1 - index,
          'occurred_at_utc': assessment.at.toUtc().toIso8601String(),
          'score': assessment.score,
          'answered': assessment.answered,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      for (var position = 0;
          position < assessment.weakSkills.length;
          position += 1) {
        final skill = _strictText(
          assessment.weakSkills[position],
          field: 'weak_skill',
          maxLength: maxIdentifierLength,
        );
        await txn.insert(
          assessmentWeakSkillsTable,
          <String, Object?>{
            'assessment_id': assessment.id,
            'position': position,
            'skill': skill,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    }

    for (var index = 0;
        index < snapshot.placementHistory.length;
        index += 1) {
      final placement = _validatePlacement(snapshot.placementHistory[index]);
      await txn.insert(
        placementTable,
        <String, Object?>{
          'placement_id': placement.id,
          'ordinal': snapshot.placementHistory.length - 1 - index,
          'occurred_at_utc': placement.at.toUtc().toIso8601String(),
          'answered': placement.answered,
          'scored_answers': placement.scoredAnswers,
          'score': placement.score,
          'confidence': placement.confidence,
          'band': placement.band.wireName,
          'curriculum_start_level': placement.curriculumStartLevel,
          'recommended_start_task_order':
              placement.recommendedStartTaskOrder,
          'learning_goal': placement.learningGoal,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      final scores = placement.dimensionScores.entries.toList()
        ..sort((a, b) => a.key.wireName.compareTo(b.key.wireName));
      for (final entry in scores) {
        await txn.insert(
          placementScoresTable,
          <String, Object?>{
            'placement_id': placement.id,
            'dimension': entry.key.wireName,
            'score': entry.value,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
      for (var position = 0;
          position < placement.weakDimensions.length;
          position += 1) {
        await txn.insert(
          placementWeakTable,
          <String, Object?>{
            'placement_id': placement.id,
            'position': position,
            'dimension': placement.weakDimensions[position].wireName,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
      for (var position = 0;
          position < placement.reviewItemIds.length;
          position += 1) {
        await txn.insert(
          placementReviewItemsTable,
          <String, Object?>{
            'placement_id': placement.id,
            'position': position,
            'item_id': _strictIdentifier(
              placement.reviewItemIds[position],
              field: 'placement_review_item_id',
            ),
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    }

    final favorites = snapshot.favoriteVerbs.toList()..sort();
    for (final verb in favorites) {
      await txn.insert(
        favoritesTable,
        <String, Object?>{
          'verb': _strictIdentifier(verb, field: 'favorite_verb'),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }

  Future<void> insertVerifiedMigrationRecord(
    DatabaseExecutor txn,
    LearnerMigrationRecord record,
  ) async {
    await txn.insert(
      migrationTable,
      record.toRow(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<LearnerSqliteApplyResult> applyAttemptOnce(
    Attempt attempt,
  ) async {
    final value = _validateAttempt(attempt);
    return _database.transaction((txn) async {
      final existing = await txn.query(
        attemptsTable,
        where: 'attempt_id = ?',
        whereArgs: <Object?>[value.id],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        if (!_attemptRowMatches(existing.single, value)) {
          throw const LearnerStateDatabaseException(
            'attempt_payload_mismatch',
          );
        }
        return LearnerSqliteApplyResult.alreadyApplied(
          revision: await loadRevision(executor: txn),
        );
      }

      final ordinal = await _nextAppendOrdinal(txn, attemptsTable);
      await txn.insert(
        attemptsTable,
        <String, Object?>{
          'attempt_id': value.id,
          'ordinal': ordinal,
          'item_id': value.itemId,
          'skill': value.skill,
          'answer': value.answer,
          'correct': value.correct ? 1 : 0,
          'hinted': value.hinted ? 1 : 0,
          'seconds': value.seconds,
          'occurred_at_utc': value.at.toUtc().toIso8601String(),
          'facet_type': value.facetType.wireName,
          'variant_key':
              ReviewFacetKey.normalizeVariant(value.variantKey) ?? '',
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _trimOldestRows(
        txn,
        table: attemptsTable,
        idColumn: 'attempt_id',
        maxRows: maxAttempts,
      );
      final revision = await _bumpRevision(txn);
      return LearnerSqliteApplyResult.applied(revision: revision);
    });
  }

  Future<LearnerSqliteApplyResult> recordAssessmentOnce(
    AssessmentHistory assessment,
  ) async {
    final value = _validateAssessment(assessment);
    return _database.transaction((txn) async {
      final existing = await txn.query(
        assessmentTable,
        where: 'assessment_id = ?',
        whereArgs: <Object?>[value.id],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        final weakRows = await txn.query(
          assessmentWeakSkillsTable,
          where: 'assessment_id = ?',
          whereArgs: <Object?>[value.id],
          orderBy: 'position ASC',
          limit: maxWeakSkills + 1,
        );
        if (!_assessmentRowsMatch(existing.single, weakRows, value)) {
          throw const LearnerStateDatabaseException(
            'assessment_payload_mismatch',
          );
        }
        return LearnerSqliteApplyResult.alreadyApplied(
          revision: await loadRevision(executor: txn),
        );
      }

      final ordinal = await _nextPrependOrdinal(txn, assessmentTable);
      await txn.insert(
        assessmentTable,
        <String, Object?>{
          'assessment_id': value.id,
          'ordinal': ordinal,
          'occurred_at_utc': value.at.toUtc().toIso8601String(),
          'score': value.score,
          'answered': value.answered,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      for (var position = 0;
          position < value.weakSkills.length;
          position += 1) {
        await txn.insert(
          assessmentWeakSkillsTable,
          <String, Object?>{
            'assessment_id': value.id,
            'position': position,
            'skill': value.weakSkills[position],
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
      await _trimOldestRows(
        txn,
        table: assessmentTable,
        idColumn: 'assessment_id',
        maxRows: maxAssessments,
      );
      final revision = await _bumpRevision(txn);
      return LearnerSqliteApplyResult.applied(revision: revision);
    });
  }

  Future<LearnerSqliteApplyResult> recordPlacementOnce(
    PlacementDiagnosticRecord placement,
  ) async {
    final value = _validatePlacement(placement);
    return _database.transaction((txn) async {
      final existing = await txn.query(
        placementTable,
        where: 'placement_id = ?',
        whereArgs: <Object?>[value.id],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        final scoreRows = await txn.query(
          placementScoresTable,
          where: 'placement_id = ?',
          whereArgs: <Object?>[value.id],
          orderBy: 'dimension ASC',
          limit: DiagnosticDimension.values.length + 1,
        );
        final weakRows = await txn.query(
          placementWeakTable,
          where: 'placement_id = ?',
          whereArgs: <Object?>[value.id],
          orderBy: 'position ASC',
          limit: DiagnosticDimension.values.length + 1,
        );
        final reviewRows = await txn.query(
          placementReviewItemsTable,
          where: 'placement_id = ?',
          whereArgs: <Object?>[value.id],
          orderBy: 'position ASC',
          limit: maxPlacementReviewItems + 1,
        );
        if (!_placementRowsMatch(
          existing.single,
          scoreRows,
          weakRows,
          reviewRows,
          value,
        )) {
          throw const LearnerStateDatabaseException(
            'placement_payload_mismatch',
          );
        }
        return LearnerSqliteApplyResult.alreadyApplied(
          revision: await loadRevision(executor: txn),
        );
      }

      final ordinal = await _nextPrependOrdinal(txn, placementTable);
      await txn.insert(
        placementTable,
        <String, Object?>{
          'placement_id': value.id,
          'ordinal': ordinal,
          'occurred_at_utc': value.at.toUtc().toIso8601String(),
          'answered': value.answered,
          'scored_answers': value.scoredAnswers,
          'score': value.score,
          'confidence': value.confidence,
          'band': value.band.wireName,
          'curriculum_start_level': value.curriculumStartLevel,
          'recommended_start_task_order':
              value.recommendedStartTaskOrder,
          'learning_goal': value.learningGoal,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      final scores = value.dimensionScores.entries.toList()
        ..sort((a, b) => a.key.wireName.compareTo(b.key.wireName));
      for (final entry in scores) {
        await txn.insert(
          placementScoresTable,
          <String, Object?>{
            'placement_id': value.id,
            'dimension': entry.key.wireName,
            'score': entry.value,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
      for (var position = 0;
          position < value.weakDimensions.length;
          position += 1) {
        await txn.insert(
          placementWeakTable,
          <String, Object?>{
            'placement_id': value.id,
            'position': position,
            'dimension': value.weakDimensions[position].wireName,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
      for (var position = 0;
          position < value.reviewItemIds.length;
          position += 1) {
        await txn.insert(
          placementReviewItemsTable,
          <String, Object?>{
            'placement_id': value.id,
            'position': position,
            'item_id': value.reviewItemIds[position],
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
      await _trimOldestRows(
        txn,
        table: placementTable,
        idColumn: 'placement_id',
        maxRows: maxPlacements,
      );
      final revision = await _bumpRevision(txn);
      return LearnerSqliteApplyResult.applied(revision: revision);
    });
  }

  Future<LearnerSqliteApplyResult> setFavoriteMembership({
    required String verb,
    required bool isFavorite,
  }) async {
    final value = _strictIdentifier(verb, field: 'favorite_verb');
    return _database.transaction((txn) async {
      final existing = await txn.query(
        favoritesTable,
        columns: const <String>['verb'],
        where: 'verb = ?',
        whereArgs: <Object?>[value],
        limit: 1,
      );
      if ((isFavorite && existing.isNotEmpty) ||
          (!isFavorite && existing.isEmpty)) {
        return LearnerSqliteApplyResult.alreadyApplied(
          revision: await loadRevision(executor: txn),
        );
      }

      if (isFavorite) {
        final count = await _countRows(txn, favoritesTable);
        if (count >= maxFavorites) {
          throw const LearnerStateDatabaseException(
            'favorite_row_bound_exceeded',
          );
        }
        await txn.insert(
          favoritesTable,
          <String, Object?>{'verb': value},
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      } else {
        await txn.delete(
          favoritesTable,
          where: 'verb = ?',
          whereArgs: <Object?>[value],
        );
      }
      final revision = await _bumpRevision(txn);
      return LearnerSqliteApplyResult.applied(revision: revision);
    });
  }

  Future<void> clearAuthoritativeStateForUserReset() async {
    await _database.transaction((txn) async {
      await txn.delete(assessmentWeakSkillsTable);
      await txn.delete(placementScoresTable);
      await txn.delete(placementWeakTable);
      await txn.delete(placementReviewItemsTable);
      await txn.delete(attemptsTable);
      await txn.delete(assessmentTable);
      await txn.delete(placementTable);
      await txn.delete(favoritesTable);
      await txn.delete(migrationTable);
      await txn.update(
        metaTable,
        <String, Object?>{
          'revision': 0,
          'last_mutated_at_utc': null,
        },
        where: 'id = 1',
      );
    });
  }

  Future<void> close() => _database.close();

  static Future<int> _countRows(
    DatabaseExecutor db,
    String table,
  ) async {
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
    final raw = rows.single['c'];
    return raw is num ? raw.toInt() : int.parse(raw.toString());
  }

  static Future<int> _nextAppendOrdinal(
    DatabaseExecutor db,
    String table,
  ) async {
    final rows = await db.rawQuery(
      'SELECT MAX(ordinal) AS value FROM $table',
    );
    final raw = rows.single['value'];
    if (raw == null) return 0;
    if (raw is! num) {
      throw const LearnerStateDatabaseException(
        'invalid_learner_store_ordinal',
      );
    }
    final current = raw.toInt();
    if (current < 0 || current >= (1 << 30)) {
      throw const LearnerStateDatabaseException(
        'learner_store_ordinal_overflow',
      );
    }
    return current + 1;
  }

  static Future<int> _nextPrependOrdinal(
    DatabaseExecutor db,
    String table,
  ) =>
      _nextAppendOrdinal(db, table);

  static Future<void> _trimOldestRows(
    DatabaseExecutor db, {
    required String table,
    required String idColumn,
    required int maxRows,
  }) async {
    final count = await _countRows(db, table);
    final overflow = count - maxRows;
    if (overflow <= 0) return;
    if (overflow > 1) {
      throw const LearnerStateDatabaseException(
        'learner_store_row_bound_corrupt',
      );
    }
    final oldest = await db.query(
      table,
      columns: <String>[idColumn],
      orderBy: 'ordinal ASC',
      limit: overflow,
    );
    for (final row in oldest) {
      await db.delete(
        table,
        where: '$idColumn = ?',
        whereArgs: <Object?>[row[idColumn]],
      );
    }
  }

  Future<int> _bumpRevision(DatabaseExecutor db) async {
    final current = await loadRevision(executor: db);
    final next = current + 1;
    if (next > (1 << 62)) {
      throw const LearnerStateDatabaseException(
        'learner_store_revision_overflow',
      );
    }
    await db.update(
      metaTable,
      <String, Object?>{
        'revision': next,
        'last_mutated_at_utc': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = 1',
    );
    return next;
  }

}
