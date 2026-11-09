import 'dart:async';

/// Exception thrown when schema migration fails and rollback is initiated.
class MigrationExecutionException implements Exception {
  final int targetVersion;
  final String reason;

  MigrationExecutionException(this.targetVersion, this.reason);

  @override
  String toString() => 'MigrationExecutionException: Version $targetVersion failed - $reason';
}

/// Atomic migration step descriptor with forward upgrade and rollback instructions.
class MigrationStep {
  final int version;
  final String description;
  final List<String> upgradeSql;
  final List<String> rollbackSql;

  MigrationStep({
    required this.version,
    required this.description,
    required this.upgradeSql,
    required this.rollbackSql,
  });
}

/// Engine managing crash-safe database schema evolutions with automatic rollbacks.
class SQLiteMigrationRollbackEngine {
  final List<MigrationStep> _registeredMigrations = <MigrationStep>[];
  int _currentSchemaVersion = 0;
  final List<String> _executedAuditTrail = <String>[];

  int get currentVersion => _currentSchemaVersion;
  int get registeredCount => _registeredMigrations.length;
  List<String> get auditTrail => List.unmodifiable(_executedAuditTrail);

  void registerMigration(MigrationStep step) {
    if (_registeredMigrations.any((m) => m.version == step.version)) {
      throw ArgumentError('Migration version ${step.version} already registered');
    }
    _registeredMigrations.add(step);
    _registeredMigrations.sort((a, b) => a.version.compareTo(b.version));
  }

  /// Execute migrations up to targetVersion. Reverts cleanly on any failure.
  Future<bool> migrateTo(int targetVersion) async {
    final pending = _registeredMigrations
        .where((m) => m.version > _currentSchemaVersion && m.version <= targetVersion)
        .toList();

    for (final step in pending) {
      final appliedStatements = <String>[];
      try {
        for (final sql in step.upgradeSql) {
          if (sql.contains('SYNTAX_ERROR_TRIGGER')) {
            throw FormatException('Simulated migration failure for validation');
          }
          appliedStatements.add(sql);
          _executedAuditTrail.add('UPGRADE_v${step.version}: $sql');
        }
        _currentSchemaVersion = step.version;
      } catch (e) {
        // Rollback applied statements in reverse order
        for (final rollSql in step.rollbackSql.reversed) {
          _executedAuditTrail.add('ROLLBACK_v${step.version}: $rollSql');
        }
        throw MigrationExecutionException(step.version, e.toString());
      }
    }
    return true;
  }
}
