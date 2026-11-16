import 'dart:async';

import 'package:flutter/foundation.dart'
    show FlutterError, FlutterErrorDetails, kReleaseMode;
import 'package:flutter/widgets.dart';

import '../features/learning/data/local_learning_recovery_pair_progress_lease.dart';
import '../services/learner_persistence.dart';
import '../services/learner_state_migration.dart';
import '../services/legacy_learner_snapshot_reader.dart';
import '../services/preferences_service.dart';
import '../services/repository.dart';
import '../services/review_transaction_reconciler.dart';
import '../core/storage/local_db/learner_state_database.dart';

final ProductionRuntimeCoordinator productionRuntimeCoordinator =
    ProductionRuntimeCoordinator();

/// Release builds keep the crash details off the console. Debug and profile
/// builds still use Flutter's presenter. This type has no print path.
final class NoopRuntimeFailureReporter {
  const NoopRuntimeFailureReporter();

  void recordFlutterError(FlutterErrorDetails details) {
    if (!kReleaseMode) {
      FlutterError.presentError(details);
    }
  }
}

/// Current production home. The deleted phase-3 screen module is not restored;
/// the shell hosts whatever widget the app passes in.
class Phase3ProductionShell extends StatelessWidget {
  const Phase3ProductionShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Recovery host for the current app. Startup accounting, safe mode, and the
/// "learner data is kept" path live in [StartupBoundary].
class LocalLearningRecoveryRuntimeHost extends StatelessWidget {
  const LocalLearningRecoveryRuntimeHost({
    super.key,
    required this.child,
    this.operations,
    this.stabilityWindow = const Duration(seconds: 6),
  });

  final Widget child;
  final StartupOperations? operations;
  final Duration stabilityWindow;

  @override
  Widget build(BuildContext context) {
    return StartupBoundary(
      operations: operations,
      stabilityWindow: stabilityWindow,
      child: child,
    );
  }
}

/// Composes the production shell around [child]. The app widget itself is
/// built by the caller so this file does not construct it.
Widget hostProductionShell({
  required Widget child,
  StartupOperations? operations,
  Duration stabilityWindow = const Duration(seconds: 6),
}) {
  return LocalLearningRecoveryRuntimeHost(
    operations: operations,
    stabilityWindow: stabilityWindow,
    child: Phase3ProductionShell(
      child: child,
    ),
  );
}

/// Installs the release error boundary, schedules a non-destructive first-frame
/// hook, then mounts [app]. Does not open the progress database.
Future<void> bootstrapDeutschApp(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();

  const runtimeFailureReporter = NoopRuntimeFailureReporter();
  FlutterError.onError = runtimeFailureReporter.recordFlutterError;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(productionRuntimeCoordinator.noteFirstFrame());
  });

  runApp(app);
}

/// Opens the versioned learner-state SQLite authority, migrates the legacy
/// prefs snapshot into it (verified, marker recorded LAST), binds it to the
/// persistence layer and hydrates the repository before it serves state to
/// the app. The legacy fallback is permanently forbidden after cutover.
Future<LearnerRepository> bindVerifiedLearnerState({
  required PreferencesService prefs,
}) async {
  final learnerStateDatabase = await LearnerStateDatabase.open();
  final legacyReader = LegacyLearnerSnapshotReader(
    prefs,
    storageKey: LearnerRepository.key,
  );
  final learnerMigration = LearnerStateMigration(
    database: learnerStateDatabase,
    legacyReader: legacyReader,
  );
  await learnerMigration.migrateAndVerify();
  final legacyFallbackAllowed =
      await learnerMigration.canFallbackToLegacy();
  final persistence = LearnerPersistence(
    prefs,
    LearnerRepository.key,
    LearnerRepository.legacyFavoriteKey,
  );
  if (legacyFallbackAllowed) {
    // Unreachable after a verified migration (revision is bumped by the
    // migration marker); fail closed rather than bind a stale authority.
    throw StateError(LearnerPersistence.staleLegacyFallbackForbidden);
  }
  await persistence.bindVerifiedSqliteAuthority(
    database: learnerStateDatabase,
    migration: learnerMigration,
  );
  final learnerRepository = LearnerRepository(
    prefs,
    persistence: persistence,
  );
  final state = learnerRepository.load();
  return learnerRepository;
}

/// Binds the canonical pair-progress authority and recovers any pending
/// review transactions before the repository serves state to the app.
Future<LocalLearningRecoveryPairProgressLease> bindLearningState({
  required LearnerRepository learnerRepository,
  required OfflinePairProgressEngine engine,
  required String sourceLanguageId,
  required String targetLanguageId,
  required bool sourceIsRtl,
  required bool targetIsRtl,
}) async {
  final lease = await LocalLearningRecoveryPairProgressLease.bind(
    repository: learnerRepository,
    sourceLanguageId: sourceLanguageId,
    targetLanguageId: targetLanguageId,
    sourceIsRtl: sourceIsRtl,
    targetIsRtl: targetIsRtl,
  );

  final reconciler = ReviewTransactionReconciler(
    engine: engine,
    gamificationSink: learnerRepository.gamificationReviewSink,
    applyAttemptOnce: (envelope) async =>
        engine.applyReviewAttemptOnce(envelope),
  );

  await reconciler.reconcilePendingReviewTransactions(limit: 128);

  final durableState = await learnerRepository.reloadPersisted();
  // durableState intentionally unused; it hydrates the repository cache.
  return lease;
}