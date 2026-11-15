import 'package:sqflite/sqflite.dart';

/// Safe SQLite Database Migration Pipeline
/// Enforces absolute isolation between Content Packs and Learner Data.
/// Strictly prohibits DROP TABLE on learner progress, favorites, and SRS tables.
class SafeLearnerMigration {
  static const Set<String> protectedUserTables = {
    'user_progress',
    'srs_reviews',
    'user_favorites',
    'placement_drafts',
    'user_weaknesses',
  };

  /// MIGRATION JOURNAL TABLE
  /// Applied migrations are journaled inside the same transaction as the
  /// schema change itself. If the process dies mid-migration, the journal
  /// rolls back with the DDL, so the next launch re-applies cleanly instead
  /// of resuming a half-migrated schema.
  static const String journalTable = 'safe_migration_journal';

  /// Verifies migration SQL statements before execution
  static bool validateMigrationStatements(List<String> statements) {
    for (final sql in statements) {
      final upper = sql.trim().toUpperCase();
      if (upper.startsWith('DROP TABLE')) {
        for (final table in protectedUserTables) {
          if (upper.contains(table.toUpperCase())) {
            // Hard violation of Master Constitution Section 09
            throw StateError('CRITICAL: Prohibited DROP TABLE detected on protected user table: $table');
          }
        }
      }
    }
    return true;
  }

  /// Migrates schema safely from oldVersion to newVersion
  static List<String> buildSafeUpgradeStatements(int oldVersion, int newVersion) {
    final statements = <String>[];

    if (oldVersion < 2) {
      // Example safe v1 -> v2 migration adding metadata columns without dropping tables
      statements.add(
        'ALTER TABLE user_progress ADD COLUMN pair_epoch INTEGER DEFAULT 1;',
      );
      statements.add(
        'ALTER TABLE user_favorites ADD COLUMN added_epoch INTEGER DEFAULT 0;',
      );
      statements.add(
        'CREATE INDEX IF NOT EXISTS idx_progress_pair ON user_progress(pair_id);',
      );
    }

    // Validate all generated statements
    validateMigrationStatements(statements);
    return statements;
  }

  /// Executes the pending migration steps inside ONE transaction together
  /// with the journal write. Statements are applied only when their effect
  /// is not already present (column checks), so the whole upgrade is
  /// idempotent and recoverable after process death.
  static Future<void> applySafeMigrations(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (db.isOpen != true) {
      throw StateError('Database must be open to apply migrations');
    }
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS $journalTable (
          migration_id TEXT PRIMARY KEY,
          applied_at_utc TEXT NOT NULL
        )
      ''');

      Future<bool> migrationApplied(String id) async {
        final rows = await txn.query(
          journalTable,
          columns: ['migration_id'],
          where: 'migration_id = ?',
          whereArgs: [id],
          limit: 1,
        );
        return rows.isNotEmpty;
      }

      Future<bool> columnExists(String table, String column) async {
        final rows = await txn.rawQuery('PRAGMA table_info($table)');
        return rows.any((row) => row['name']?.toString() == column);
      }

      Future<void> addColumnIfMissing(
        String table,
        String column,
        String definition,
      ) async {
        if (await columnExists(table, column)) {
          return; // already applied (idempotency)
        }
        await txn.execute(
          'ALTER TABLE $table ADD COLUMN $column $definition',
        );
      }

      if (oldVersion < 2 && newVersion >= 2) {
        const id = 'safe_v1_to_v2';
        if (!await migrationApplied(id)) {
          await addColumnIfMissing('user_progress', 'pair_epoch', 'INTEGER DEFAULT 1');
          await addColumnIfMissing('user_favorites', 'added_epoch', 'INTEGER DEFAULT 0');
          await txn.execute(
            'CREATE INDEX IF NOT EXISTS idx_progress_pair ON user_progress(pair_id)',
          );
          await txn.insert(
            journalTable,
            <String, Object?>{
              'migration_id': id,
              'applied_at_utc': DateTime.now().toUtc().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    });
  }
}
