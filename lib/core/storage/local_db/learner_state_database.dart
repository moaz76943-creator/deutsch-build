import 'package:sqflite_common/sqlite_api.dart';

import '../../../models/learner.dart';
import '../../../models/diagnostic_placement.dart';
import '../../srs_facets.dart';
import '../../../services/sqlite_policy.dart';

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
}

final class LearnerStateDatabaseException implements Exception {
  const LearnerStateDatabaseException(this.code);

  final String code;

  @override
  String toString() => 'LearnerStateDatabaseException($code)';
}