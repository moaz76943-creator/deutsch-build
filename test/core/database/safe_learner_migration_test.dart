import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/database/safe_learner_migration.dart';

void main() {
  group('Safe SQLite Migration - Learner Data Preservation', () {
    test('Throws StateError and blocks execution if DROP TABLE targets protected user tables', () {
      final unsafeStatements = [
        'CREATE TABLE temp_content (id TEXT);',
        'DROP TABLE user_progress;', // Dangerous statement
      ];

      expect(
        () => SafeLearnerMigration.validateMigrationStatements(unsafeStatements),
        throwsA(isA<StateError>()),
      );
    });

    test('Allows safe ALTER TABLE and index additions across schema upgrades', () {
      final upgradeSql = SafeLearnerMigration.buildSafeUpgradeStatements(1, 2);

      expect(upgradeSql.isNotEmpty, isTrue);
      expect(upgradeSql.any((s) => s.contains('ALTER TABLE user_progress')), isTrue);
      expect(upgradeSql.any((s) => s.contains('ALTER TABLE user_favorites')), isTrue);
      expect(upgradeSql.any((s) => s.contains('DROP TABLE')), isFalse);
    });
  });
}
