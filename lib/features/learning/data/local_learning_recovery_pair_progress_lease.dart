import '../../../core/models/language_catalog_models.dart';
import '../../../core/packs/pack_models.dart';
import '../../../core/progress/offline_pair_progress_engine.dart';
import '../../../core/storage/local_db/pair_progress_database.dart';
import '../../../services/repository.dart';
import '../../../services/sqlite_policy.dart';

/// Owns the database connection used by the existing canonical pair-progress
/// authority. It does not introduce a second progress model or scheduler.
final class LocalLearningRecoveryPairProgressLease {
  const LocalLearningRecoveryPairProgressLease._(this._store);

  static const String databaseFileName = 'pair_progress_v2.db';

  final PairProgressDatabase? _store;

  static Future<LocalLearningRecoveryPairProgressLease> bind({
    required LearnerRepository repository,
    required String sourceLanguageId,
    required String targetLanguageId,
    required bool sourceIsRtl,
    required bool targetIsRtl,
    required int migratedAchievementPoints,
    AppSqlitePolicy sqlitePolicy = const AppSqlitePolicy(),
  }) async {
    if (repository.hasPairProgressAuthority) {
      return const LocalLearningRecoveryPairProgressLease._(null);
    }

    final request = PackPairRequest(
      sourceLanguageTag: sourceLanguageId,
      targetLanguageTag: targetLanguageId,
    );
    final path = await sqlitePolicy.resolvePath(fileName: databaseFileName);
    final database = await sqlitePolicy.openWritable(
      path: path,
      version: PairProgressDatabase.schemaVersion,
    );

    try {
      final store = await PairProgressDatabase.attach(database);
      final engine = OfflinePairProgressEngine(store);
      final pair = ResolvedLanguagePair(
        source: LanguageMetadata(
          id: request.source,
          name: request.source.toUpperCase(),
          isRtl: sourceIsRtl,
        ),
        target: LanguageMetadata(
          id: request.target,
          name: request.target.toUpperCase(),
          isRtl: targetIsRtl,
        ),
        pairKey: request.pairKey,
        generation: 0,
        route: PackRouteDecision(
          request: request,
          availability: PackAvailabilityStatus.available,
          status: PackAcquisitionStatus.localReady,
          localPack: null,
          providerCandidates: const <String>[],
        ),
      );

      final legacy = repository.load();
      final needsMigration = legacy.reviewCards.isNotEmpty ||
          legacy.learned.isNotEmpty ||
          legacy.review.isNotEmpty;
      await repository.bindPairProgressAuthority(
        engine: engine,
        pair: pair,
        migrateLegacy: needsMigration,
        migratedAchievementPoints: migratedAchievementPoints,
      );
      return LocalLearningRecoveryPairProgressLease._(store);
    } on Object {
      await database.close();
      rethrow;
    }
  }

  Future<void> close() async {
    await _store?.close();
  }
}
