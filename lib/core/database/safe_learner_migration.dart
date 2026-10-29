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
}
