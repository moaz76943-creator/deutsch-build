import '../core/storage/local_db/learner_state_database.dart';
import 'legacy_learner_snapshot_reader.dart';

enum LearnerStateMigrationStatus {
  migrated,
  alreadyVerified,
}

final class LearnerStateMigrationResult {
  const LearnerStateMigrationResult({
    required this.status,
    required this.record,
  });

  final LearnerStateMigrationStatus status;
  final LearnerMigrationRecord record;
}

final class LearnerStateMigration {
  LearnerStateMigration({
    required this.database,
    required this.legacyReader,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const String migrationId =
      'shared_preferences_v34_to_learner_sqlite_v1';
  static const int migrationVersion = 1;

  final LearnerStateDatabase database;
  final LegacyLearnerSnapshotReader legacyReader;
  final DateTime Function() _now;

  Future<LearnerStateMigrationResult> migrateAndVerify() async {
    final existing = await database.loadMigrationRecord(migrationId);
    if (existing != null) {
      await _verifyCommittedRecord(existing);
      return LearnerStateMigrationResult(
        status: LearnerStateMigrationStatus.alreadyVerified,
        record: existing,
      );
    }

    if (await database.hasDomainRows()) {
      throw const LearnerStateMigrationException(
        'unverified_learner_sqlite_state',
      );
    }

    final source = await legacyReader.readStrict();

    final record = await database.transaction((txn) async {
      final existingInside = await database.loadMigrationRecord(
        migrationId,
        executor: txn,
      );
      if (existingInside != null) {
        await _verifyRecordAgainstSnapshot(
          existingInside,
          await database.readSnapshot(executor: txn),
        );
        return existingInside;
      }

      final unexpectedMarkers = await txn.query(
        LearnerStateDatabase.migrationTable,
        columns: const <String>['migration_id'],
        limit: 1,
      );
      if (unexpectedMarkers.isNotEmpty) {
        throw const LearnerStateMigrationException(
          'unexpected_learner_migration_record',
        );
      }

      if (await database.hasDomainRows(executor: txn)) {
        throw const LearnerStateMigrationException(
          'unverified_learner_sqlite_state',
        );
      }

      final revision = await database.loadRevision(executor: txn);
      if (revision != 0) {
        throw const LearnerStateMigrationException(
          'learner_store_revision_not_pristine',
        );
      }

      await database.importSnapshot(txn, source.sqliteSnapshot);

      final imported = await database.readSnapshot(executor: txn);
      final importedHash =
          await LegacyLearnerSnapshotReader.canonicalSnapshotSha256(
        imported,
      );
      _verifyImportedSnapshot(
        source: source,
        imported: imported,
        importedHash: importedHash,
      );

      final completedAt = _now().toUtc();
      final verified = LearnerMigrationRecord(
        migrationId: migrationId,
        migrationVersion: migrationVersion,
        sourceStorageKey: legacyReader.storageKey,
        sourcePayloadSha256: source.sourcePayloadSha256,
        sourceLegacyFavoritesSha256:
            source.sourceLegacyFavoritesSha256,
        importedSnapshotSha256: importedHash,
        attemptCount: imported.attempts.length,
        assessmentCount: imported.assessmentHistory.length,
        placementCount: imported.placementHistory.length,
        favoriteCount: imported.favoriteVerbs.length,
        completedAtUtc: completedAt,
        cutoverRevision: revision,
      );
      await database.insertVerifiedMigrationRecord(txn, verified);
      return verified;
    });

    await _verifyCommittedRecord(record);
    return LearnerStateMigrationResult(
      status: LearnerStateMigrationStatus.migrated,
      record: record,
    );
  }

  Future<void> _verifyCommittedRecord(
    LearnerMigrationRecord record,
  ) async {
    if (record.migrationId != migrationId ||
        record.migrationVersion != migrationVersion ||
        record.sourceStorageKey != legacyReader.storageKey) {
      throw const LearnerStateMigrationException(
        'migration_record_identity_mismatch',
      );
    }

    final persisted = await database.loadMigrationRecord(migrationId);
    if (persisted == null) {
      throw const LearnerStateMigrationException(
        'migration_record_missing_after_commit',
      );
    }
    _verifyRecordIdentity(record, persisted);

    final revision = await database.loadRevision();
    if (revision < persisted.cutoverRevision) {
      throw const LearnerStateMigrationException(
        'learner_store_revision_regressed',
      );
    }

    final snapshot = await database.readSnapshot();
    if (revision == persisted.cutoverRevision) {
      await _verifyRecordAgainstSnapshot(persisted, snapshot);
    }
  }

  Future<bool> canFallbackToLegacy() async {
    try {
      final revision = await database.loadRevision();
      if (revision != 0) return false;
      final marker = await database.loadMigrationRecord(migrationId);
      if (marker != null) return false;
      return !await database.hasDomainRows();
    } on Object {
      return false;
    }
  }

  static Future<void> _verifyRecordAgainstSnapshot(
    LearnerMigrationRecord record,
    LearnerSqliteSnapshot snapshot,
  ) async {
    final hash =
        await LegacyLearnerSnapshotReader.canonicalSnapshotSha256(snapshot);
    if (hash != record.importedSnapshotSha256 ||
        snapshot.attempts.length != record.attemptCount ||
        snapshot.assessmentHistory.length != record.assessmentCount ||
        snapshot.placementHistory.length != record.placementCount ||
        snapshot.favoriteVerbs.length != record.favoriteCount) {
      throw const LearnerStateMigrationException(
        'learner_sqlite_readback_mismatch',
      );
    }
  }

  static void _verifyImportedSnapshot({
    required LegacyLearnerMigrationSnapshot source,
    required LearnerSqliteSnapshot imported,
    required String importedHash,
  }) {
    if (importedHash != source.canonicalSnapshotSha256 ||
        imported.attempts.length != source.attemptCount ||
        imported.assessmentHistory.length != source.assessmentCount ||
        imported.placementHistory.length != source.placementCount ||
        imported.favoriteVerbs.length != source.favoriteCount) {
      throw const LearnerStateMigrationException(
        'learner_sqlite_import_verification_failed',
      );
    }
  }

  static void _verifyRecordIdentity(
    LearnerMigrationRecord expected,
    LearnerMigrationRecord actual,
  ) {
    if (expected.migrationId != actual.migrationId ||
        expected.migrationVersion != actual.migrationVersion ||
        expected.sourceStorageKey != actual.sourceStorageKey ||
        expected.sourcePayloadSha256 != actual.sourcePayloadSha256 ||
        expected.sourceLegacyFavoritesSha256 !=
            actual.sourceLegacyFavoritesSha256 ||
        expected.importedSnapshotSha256 !=
            actual.importedSnapshotSha256 ||
        expected.attemptCount != actual.attemptCount ||
        expected.assessmentCount != actual.assessmentCount ||
        expected.placementCount != actual.placementCount ||
        expected.favoriteCount != actual.favoriteCount ||
        expected.completedAtUtc.toUtc().microsecondsSinceEpoch !=
            actual.completedAtUtc.toUtc().microsecondsSinceEpoch ||
        expected.cutoverRevision != actual.cutoverRevision) {
      throw const LearnerStateMigrationException(
        'migration_record_readback_mismatch',
      );
    }
  }
}

final class LearnerStateMigrationException implements Exception {
  const LearnerStateMigrationException(this.code);

  final String code;

  @override
  String toString() => 'LearnerStateMigrationException($code)';
}
