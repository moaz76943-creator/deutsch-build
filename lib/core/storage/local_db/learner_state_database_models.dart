part of 'learner_state_database.dart';

enum LearnerSqliteApplyStatus {
  applied,
  alreadyApplied,
}

final class LearnerSqliteApplyResult {
  const LearnerSqliteApplyResult._({
    required this.status,
    required this.revision,
  });

  const LearnerSqliteApplyResult.applied({required int revision})
      : this._(
          status: LearnerSqliteApplyStatus.applied,
          revision: revision,
        );

  const LearnerSqliteApplyResult.alreadyApplied({required int revision})
      : this._(
          status: LearnerSqliteApplyStatus.alreadyApplied,
          revision: revision,
        );

  final LearnerSqliteApplyStatus status;
  final int revision;

  bool get alreadyApplied =>
      status == LearnerSqliteApplyStatus.alreadyApplied;
}

final class LearnerSqliteSnapshot {
  const LearnerSqliteSnapshot({
    required this.attempts,
    required this.assessmentHistory,
    required this.placementHistory,
    required this.favoriteVerbs,
  });

  final List<Attempt> attempts;
  final List<AssessmentHistory> assessmentHistory;
  final List<PlacementDiagnosticRecord> placementHistory;
  final Set<String> favoriteVerbs;
}

final class LearnerMigrationRecord {
  const LearnerMigrationRecord({
    required this.migrationId,
    required this.migrationVersion,
    required this.sourceStorageKey,
    required this.sourcePayloadSha256,
    required this.sourceLegacyFavoritesSha256,
    required this.importedSnapshotSha256,
    required this.attemptCount,
    required this.assessmentCount,
    required this.placementCount,
    required this.favoriteCount,
    required this.completedAtUtc,
    required this.cutoverRevision,
  });

  final String migrationId;
  final int migrationVersion;
  final String sourceStorageKey;
  final String sourcePayloadSha256;
  final String sourceLegacyFavoritesSha256;
  final String importedSnapshotSha256;
  final int attemptCount;
  final int assessmentCount;
  final int placementCount;
  final int favoriteCount;
  final DateTime completedAtUtc;
  final int cutoverRevision;

  Map<String, Object?> toRow() => <String, Object?>{
        'migration_id': migrationId,
        'migration_version': migrationVersion,
        'status': 'verified',
        'source_storage_key': sourceStorageKey,
        'source_payload_sha256': sourcePayloadSha256,
        'source_legacy_favorites_sha256':
            sourceLegacyFavoritesSha256,
        'imported_snapshot_sha256': importedSnapshotSha256,
        'attempt_count': attemptCount,
        'assessment_count': assessmentCount,
        'placement_count': placementCount,
        'favorite_count': favoriteCount,
        'completed_at_utc': completedAtUtc.toUtc().toIso8601String(),
        'cutover_revision': cutoverRevision,
      };

  factory LearnerMigrationRecord.fromRow(Map<String, Object?> row) {
    final status = row['status']?.toString();
    if (status != 'verified') {
      throw const LearnerStateDatabaseException(
        'invalid_migration_status',
      );
    }
    final completed =
        DateTime.tryParse(row['completed_at_utc']?.toString() ?? '')?.toUtc();
    if (completed == null) {
      throw const LearnerStateDatabaseException(
        'invalid_migration_completed_at',
      );
    }

    String hash(String field) {
      final value = row[field]?.toString().trim().toLowerCase() ?? '';
      if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
        throw LearnerStateDatabaseException('invalid_$field');
      }
      return value;
    }

    int integer(String field, {int max = 1 << 30}) {
      final raw = row[field];
      if (raw is! num || raw.toInt() != raw) {
        throw LearnerStateDatabaseException('invalid_$field');
      }
      final value = raw.toInt();
      if (value < 0 || value > max) {
        throw LearnerStateDatabaseException('invalid_$field');
      }
      return value;
    }

    final id = row['migration_id']?.toString().trim() ?? '';
    final sourceKey = row['source_storage_key']?.toString().trim() ?? '';
    if (id.isEmpty ||
        id.length > LearnerStateDatabase.maxIdentifierLength ||
        sourceKey.isEmpty ||
        sourceKey.length > LearnerStateDatabase.maxIdentifierLength) {
      throw const LearnerStateDatabaseException(
        'invalid_migration_identity',
      );
    }

    return LearnerMigrationRecord(
      migrationId: id,
      migrationVersion: integer('migration_version', max: 1000),
      sourceStorageKey: sourceKey,
      sourcePayloadSha256: hash('source_payload_sha256'),
      sourceLegacyFavoritesSha256:
          hash('source_legacy_favorites_sha256'),
      importedSnapshotSha256: hash('imported_snapshot_sha256'),
      attemptCount: integer(
        'attempt_count',
        max: LearnerStateDatabase.maxAttempts,
      ),
      assessmentCount: integer(
        'assessment_count',
        max: LearnerStateDatabase.maxAssessments,
      ),
      placementCount: integer(
        'placement_count',
        max: LearnerStateDatabase.maxPlacements,
      ),
      favoriteCount: integer(
        'favorite_count',
        max: LearnerStateDatabase.maxFavorites,
      ),
      completedAtUtc: completed,
      cutoverRevision: integer('cutover_revision', max: 1 << 30),
    );
  }
}

final class LearnerStateDatabaseException implements Exception {
  const LearnerStateDatabaseException(this.code);

  final String code;

  @override
  String toString() => 'LearnerStateDatabaseException($code)';
}
