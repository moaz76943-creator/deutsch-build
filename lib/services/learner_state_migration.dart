import '../core/storage/local_db/learner_state_database.dart';
import 'legacy_learner_snapshot_reader.dart';

/// One-time, verified migration of the legacy prefs learner snapshot into
/// the versioned learner-state SQLite store.
///
/// The cutover is transactional and marked verified LAST: import happens
/// inside a single transaction, the imported payload is read back and
/// digest-compared against the legacy source, and only then is the
/// migration record (which bumps the store revision and closes the
/// legacy fallback) inserted. Any failure leaves the store pristine
/// (revision 0) and the legacy prefs path untouched.
final class LearnerStateMigration {
  const LearnerStateMigration({
    required this.database,
    required this.legacyReader,
  });

  static const String migrationId =
      'shared_preferences_v34_to_learner_sqlite_v1';

  final LearnerStateDatabase database;
  final LegacyLearnerSnapshotReader legacyReader;

  /// Migrates the four legacy domains and records the verified cutover.
  /// Idempotent: an already-promoted store (revision != 0) is left
  /// untouched.
  Future<void> migrateAndVerify() async {
    final pristineRevision = await database.readRevision();
    if (pristineRevision != 0) return;

    final source = await legacyReader.readSnapshot();

    await database.transaction((txn) async {
      await database.importSnapshot(source, executor: txn);

      // Read back the uncommitted rows through the migration transaction
      // and verify against the legacy source before marking cutover.
      final imported = await database.readSnapshot(executor: txn);
      _verifyImportedSnapshot(source: source, imported: imported);

      await database.insertVerifiedMigrationRecord(
        snapshot: imported,
        executor: txn,
        migrationId: migrationId,
      );
    });
  }

  /// True only while the store is pristine (revision 0): the legacy
  /// fallback is valid exclusively before the verified cutover is
  /// recorded. After cutover it is forbidden.
  Future<bool> canFallbackToLegacy() async {
    try {
      final revision = await database.readRevision();
      if (revision != 0) return false;
      return true;
    } on Object {
      // Fail closed: an unreadable store never re-opens the legacy path.
      return false;
    }
  }

  static void _verifyImportedSnapshot({
    required LearnerStateSnapshot source,
    required LearnerStateSnapshot imported,
  }) {
    if (imported.canonicalSnapshotSha256 != source.canonicalSnapshotSha256 ||
        imported.attempts.length != source.attempts.length ||
        imported.assessmentHistory.length !=
            source.assessmentHistory.length ||
        imported.placementHistory.length != source.placementHistory.length ||
        imported.favoriteVerbs.length != source.favoriteVerbs.length) {
      throw const LearnerStateMigrationException(
        'learner_sqlite_import_verification_failed',
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
