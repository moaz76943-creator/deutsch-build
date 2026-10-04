import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'core/agents/agents.dart';
import 'core/content_contract.dart';
import 'core/curriculum/canonical_curriculum_50.dart';
import 'core/curriculum/curriculum_models.dart';
import 'core/infrastructure/audio/flutter_tts_audio_engine.dart';
import 'features/audio/offline_audio_runtime.dart';
import 'features/learning/data/local_learning_recovery_pair_progress_lease.dart';
import 'features/learning/presentation/local_learning_recovery_runtime_host.dart';
import 'features/placement/application/placement_test_notifier.dart';
import 'features/placement/data/learner_placement_profile_repository.dart';
import 'features/placement/data/local_placement_repository.dart';
import 'features/placement/data/placement_audio_runtime_adapter.dart';
import 'features/placement/presentation/placement_test_screen.dart';
import 'language/german/german_language_pack.dart';
import 'language/german/german_speech_profile.dart';
import 'models/learner.dart';
import 'models/pack_security_runtime_config.dart';
import 'services/active_pack_runtime_provider.dart';
import 'services/grammar_hub_service.dart';
import 'services/learner_persistence.dart';
import 'services/open_source_license_registry.dart';
import 'services/pack_database_key_store.dart';
import 'services/pack_database_security.dart';
import 'services/pack_manager_service.dart';
import 'services/preferences_service.dart';
import 'services/repository.dart';
import 'services/runtime_failure_reporter.dart';
import 'ui/bridge/agent_ui_bridge.dart';
import 'ui/phase3/phase3_production_shell.dart';

SystemAgentRuntime? _systemAgentRuntime;

const _ProductionUiContract _productionUi = _ProductionUiContract(
  appName: 'Salim',
  showDebugBanner: false,
);

final class _ProductionUiContract {
  const _ProductionUiContract({
    required this.appName,
    required this.showDebugBanner,
  });

  final String appName;
  final bool showDebugBanner;
}

void _verifyProductionContract() {
  if (_productionUi.appName != 'Salim') {
    throw StateError('Production app name must remain Salim.');
  }
  if (_productionUi.showDebugBanner) {
    throw StateError('Production debug banner must remain disabled.');
  }
  if (CanonicalCurriculum50.tasks.length != 50) {
    throw StateError('Canonical production curriculum must contain 50 tasks.');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerProjectOpenSourceLicenses();

  const runtimeFailureReporter = NoopRuntimeFailureReporter();

  FlutterError.onError = (FlutterErrorDetails details) {
    runtimeFailureReporter.recordFlutterError(details);
    unawaited(
      _dispatchRecoveryError(
        error: details.exception,
        context: 'flutter.framework',
        fatal: false,
      ),
    );
    if (!kReleaseMode) {
      FlutterError.presentError(details);
    }
  };

  ErrorWidget.builder = (FlutterErrorDetails details) => const Material(
        child: _InlineSafeError(),
      );

  await runZonedGuarded(
    () async {
      try {
        _verifyProductionContract();
        final prefs = await PreferencesService.instance();
        final learnerRepository = LearnerRepository(
          prefs,
          persistence: LearnerPersistence(
            prefs,
            LearnerRepository.key,
            LearnerRepository.legacyFavoriteKey,
          ),
        );
        final state = learnerRepository.load();

        if (_needsPlacementOnboarding(state)) {
          runApp(
            _PlacementBootstrapApp(
              prefs: prefs,
              learnerRepository: learnerRepository,
            ),
          );
          return;
        }

        runApp(
          await _activateProduction(
            prefs: prefs,
            learnerRepository: learnerRepository,
          ),
        );
      } catch (error, stack) {
        runtimeFailureReporter.record(
          error,
          stack,
          fatal: true,
          context: 'bootstrap',
        );
        await _dispatchRecoveryError(
          error: error,
          context: 'bootstrap',
          fatal: true,
        );
        runApp(const _BootFailureApp());
      }
    },
    (error, stack) {
      runtimeFailureReporter.record(
        error,
        stack,
        fatal: true,
        context: 'root_zone',
      );
      unawaited(
        _dispatchRecoveryError(
          error: error,
          context: 'root_zone',
          fatal: true,
        ),
      );
    },
  );
}

Future<_ActivatedPhase3App> _activateProduction({
  required PreferencesService prefs,
  required LearnerRepository learnerRepository,
}) async {
  final systemAgents = await SystemAgentRuntime.start(
    memoryStore: _PreferencesMemoryAgentStore(prefs),
  );
  _systemAgentRuntime = systemAgents;
  LocalLearningRecoveryPairProgressLease? recoveryPairProgress;

  try {
    const activeLanguagePack = GermanLanguagePack();
    recoveryPairProgress = await LocalLearningRecoveryPairProgressLease.bind(
      repository: learnerRepository,
      sourceLanguageId: activeLanguagePack.sourceLocale,
      targetLanguageId: activeLanguagePack.languageCode,
      sourceIsRtl: true,
      targetIsRtl: false,
    );
    final durableState = await learnerRepository.reloadPersisted();
    await _seedMemoryOnce(
      runtime: systemAgents,
      state: durableState,
    );
    final corpus = await _resolveActiveCorpus(prefs);
    final uiBridge = AgentUIBridge.attach(systemAgents);
    final routeState = await learnerRepository.reloadPersisted();

    return _ActivatedPhase3App(
      corpus: corpus,
      bridge: uiBridge,
      preferences: prefs,
      learnerRepository: learnerRepository,
      startTaskOrder: _placementStartTaskOrder(routeState),
      shutdown: () async {
        await recoveryPairProgress?.close();
        await _shutdownActivatedRuntime(
          runtime: systemAgents,
          bridge: uiBridge,
        );
      },
    );
  } catch (_) {
    final pairProgress = recoveryPairProgress;
    if (pairProgress != null) {
      try {
        await pairProgress.close();
      } on Object {
        // Preserve the original activation failure.
      }
    }
    await systemAgents.close().catchError((_) {});
    if (identical(_systemAgentRuntime, systemAgents)) {
      _systemAgentRuntime = null;
    }
    rethrow;
  }
}

bool _needsPlacementOnboarding(LearnerState state) =>
    state.placementHistory.isEmpty &&
    state.attempts.isEmpty &&
    state.assessmentHistory.isEmpty &&
    state.learned.isEmpty &&
    state.reviewCards.isEmpty &&
    state.xp == 0;

int _placementStartTaskOrder(LearnerState state) {
  for (final record in state.placementHistory) {
    if (record.curriculumStartLevel == null) continue;
    return record.recommendedStartTaskOrder.clamp(1, 50).toInt();
  }
  return 1;
}

Future<List<LearningContent>> _resolveActiveCorpus(
  PreferencesService prefs,
) async {
  final databaseRoot = await getDatabasesPath();
  final languagePack = const GermanLanguagePack();
  final packSecurity = PackSecurityRuntimeConfig.fromEnvironment();
  final manifestVerifier = PackManifestVerifiers.fromSingleBase64Key(
    keyId: packSecurity.manifestKeyId,
    publicKeyBase64: packSecurity.manifestPublicKeyBase64,
  );
  final packDatabaseKeyStore = AndroidKeystorePackDatabaseKeyStore();
  const packDatabaseSecurity = SqlCipherPackDatabaseSecurity();

  final packManager = PackManagerService(
    prefs,
    manifestVerifier: manifestVerifier,
    databaseKeyStore: packDatabaseKeyStore,
    databaseCipher: packDatabaseSecurity,
    rootDirectory: Directory(
      p.join(databaseRoot, 'offline_language_packs'),
    ),
  );

  final resolution = await ActivePackRuntimeProvider(
    packManager: packManager,
    languagePack: languagePack,
    embeddedGrammar: GrammarHubService(),
    databaseKeyStore: packDatabaseKeyStore,
    databaseOpener: packDatabaseSecurity,
  ).resolve();

  return List<LearningContent>.unmodifiable(
    resolution.languagePack.contentPack.items,
  );
}

Future<void> _seedMemoryOnce({
  required SystemAgentRuntime runtime,
  required LearnerState state,
}) async {
  if (runtime.memorySnapshot.tasks.isNotEmpty ||
      runtime.memorySnapshot.weaknesses.isNotEmpty ||
      state.attempts.isEmpty) {
    return;
  }

  final recentAttempts = state.attempts.length <= 300
      ? state.attempts
      : state.attempts.sublist(state.attempts.length - 300);
  final aggregates = <String, _SeedTaskAggregate>{};

  for (final attempt in recentAttempts) {
    final task = _taskForSkill(attempt.skill);
    final aggregate = aggregates.putIfAbsent(
      task.id,
      () => _SeedTaskAggregate(task),
    );
    aggregate.record(attempt);

    if (!attempt.correct) {
      runtime.recordMistake(
        taskId: task.id,
        weaknessKey: _weaknessKey(attempt),
        weight: attempt.hinted ? 2 : 1,
        occurredAtEpochMs: attempt.at.millisecondsSinceEpoch,
      );
    }
  }

  for (final aggregate in aggregates.values) {
    final score = aggregate.total == 0
        ? 0.0
        : aggregate.correct / aggregate.total;
    runtime.recordProgress(
      taskId: aggregate.task.id,
      score: score,
      completed:
          aggregate.total >= 2 && score >= aggregate.task.masteryThreshold,
      attempts: aggregate.total,
      occurredAtEpochMs: aggregate.latestEpochMs,
    );
  }

  for (final assessment in state.assessmentHistory.take(20)) {
    for (final weakSkill in assessment.weakSkills) {
      final task = _taskForSkill(weakSkill);
      runtime.recordMistake(
        taskId: task.id,
        weaknessKey: 'assessment:${weakSkill.trim().toLowerCase()}',
        weight: 2,
        occurredAtEpochMs: assessment.at.millisecondsSinceEpoch,
      );
    }
  }

  await runtime.flushMemory();
}

CurriculumTask _taskForSkill(String rawSkill) {
  final skill = rawSkill.trim().toLowerCase();

  for (final task in CanonicalCurriculum50.tasks) {
    if (task.skill.toLowerCase() == skill) return task;
  }

  if (skill.contains('listen')) {
    return CanonicalCurriculum50.tasks
        .firstWhere((task) => task.skill == 'listening');
  }
  if (skill.contains('speak') || skill.contains('production')) {
    return CanonicalCurriculum50.tasks
        .firstWhere((task) => task.skill == 'speaking');
  }
  if (skill.contains('writ')) {
    return CanonicalCurriculum50.tasks
        .firstWhere((task) => task.skill == 'writing');
  }
  if (skill.contains('gram')) {
    return CanonicalCurriculum50.tasks
        .firstWhere((task) => task.skill == 'grammar');
  }
  if (skill.contains('read')) {
    return CanonicalCurriculum50.tasks
        .firstWhere((task) => task.skill == 'reading');
  }
  if (skill.contains('vocab') || skill.contains('recall')) {
    return CanonicalCurriculum50.tasks
        .firstWhere((task) => task.skill == 'vocabulary');
  }

  return CanonicalCurriculum50.tasks[47];
}

String _weaknessKey(Attempt attempt) {
  final skill = attempt.skill.trim().toLowerCase();
  final item = attempt.itemId.trim().toLowerCase();
  final facet = attempt.facetType.name;
  final raw = '$skill:$item:$facet';
  return raw.length <= 160 ? raw : raw.substring(0, 160);
}

Future<void> _dispatchRecoveryError({
  required Object error,
  required String context,
  required bool fatal,
}) async {
  final runtime = _systemAgentRuntime;
  if (runtime == null || runtime.isClosed) return;
  try {
    await runtime.reportError(
      context: context,
      errorType: error.runtimeType.toString(),
      message: error.toString(),
      fatal: fatal,
    );
  } on Object {
    return;
  }
}

Future<void> _shutdownActivatedRuntime({
  required SystemAgentRuntime runtime,
  required AgentUIBridge bridge,
}) async {
  await bridge.close();
  await runtime.close();
  if (identical(_systemAgentRuntime, runtime)) {
    _systemAgentRuntime = null;
  }
}

final class _PreferencesMemoryAgentStore implements MemoryAgentStore {
  const _PreferencesMemoryAgentStore(this.preferences);

  static const String storageKey = 'sys_memory_agent_v1';

  final PreferencesService preferences;

  @override
  Future<String?> read() async => preferences.getString(storageKey);

  @override
  Future<void> write(String encoded) async {
    final written = await preferences.setString(storageKey, encoded);
    if (!written) {
      throw StateError('Memory agent storage write failed.');
    }
  }
}

final class _SeedTaskAggregate {
  _SeedTaskAggregate(this.task);

  final CurriculumTask task;
  int total = 0;
  int correct = 0;
  int latestEpochMs = 0;

  void record(Attempt attempt) {
    total += 1;
    if (attempt.correct) correct += 1;
    final occurredAt = attempt.at.millisecondsSinceEpoch;
    if (occurredAt > latestEpochMs) {
      latestEpochMs = occurredAt;
    }
  }
}

final class _PlacementBootstrapApp extends StatefulWidget {
  const _PlacementBootstrapApp({
    required this.prefs,
    required this.learnerRepository,
  });

  final PreferencesService prefs;
  final LearnerRepository learnerRepository;

  @override
  State<_PlacementBootstrapApp> createState() =>
      _PlacementBootstrapAppState();
}

final class _PlacementBootstrapAppState
    extends State<_PlacementBootstrapApp> {
  late final OfflineAudioRuntime _placementAudio;
  late final PlacementTestNotifier _notifier;

  _ActivatedPhase3App? _activated;
  bool _activating = false;
  bool _audioClosed = false;
  Object? _activationError;

  @override
  void initState() {
    super.initState();
    _placementAudio = OfflineAudioRuntime(
      speechProfile: const GermanSpeechProfile(),
      ttsEngine: FlutterOfflineTtsEngine(),
    );
    _notifier = PlacementTestNotifier(
      repository: const LocalPlacementRepository(),
      profileRepository:
          LearnerPlacementProfileRepository(widget.learnerRepository),
      audioGateway: PlacementAudioRuntimeAdapter(_placementAudio),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    unawaited(_closePlacementAudio());
    super.dispose();
  }

  Future<void> _closePlacementAudio() async {
    if (_audioClosed) return;
    _audioClosed = true;
    await _placementAudio.shutdown();
  }

  Future<void> _activate() async {
    if (_activating) return;
    setState(() {
      _activating = true;
      _activationError = null;
    });

    try {
      await _closePlacementAudio();
      final app = await _activateProduction(
        prefs: widget.prefs,
        learnerRepository: widget.learnerRepository,
      );
      if (!mounted) {
        await app.shutdown();
        return;
      }
      setState(() {
        _activated = app;
        _activating = false;
      });
    } catch (error) {
      await _dispatchRecoveryError(
        error: error,
        context: 'placement.activate',
        fatal: false,
      );
      if (!mounted) return;
      setState(() {
        _activationError = error;
        _activating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activated = _activated;
    if (activated != null) return activated;

    return MaterialApp(
      debugShowCheckedModeBanner: _productionUi.showDebugBanner,
      title: _productionUi.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: _activationError != null
          ? _PlacementActivationFailure(
              onRetry: () => unawaited(_activate()),
            )
          : _activating
              ? const _PlacementActivationLoading()
              : PlacementTestScreen(
                  notifier: _notifier,
                  onStartLearning: () => unawaited(_activate()),
                ),
    );
  }
}

final class _PlacementActivationLoading extends StatelessWidget {
  const _PlacementActivationLoading();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'تم حفظ مستواك. جاري تجهيز مسارك المحلي…',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

final class _PlacementActivationFailure extends StatelessWidget {
  const _PlacementActivationFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.error_outline_rounded, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'تم حفظ نتيجة الاختبار، لكن تعذر تجهيز المحتوى المحلي.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

final class _ActivatedPhase3App extends StatefulWidget {
  const _ActivatedPhase3App({
    required this.corpus,
    required this.bridge,
    required this.preferences,
    required this.learnerRepository,
    required this.startTaskOrder,
    required this.shutdown,
  });

  final List<LearningContent> corpus;
  final AgentUIBridge bridge;
  final PreferencesService preferences;
  final LearnerRepository learnerRepository;
  final int startTaskOrder;
  final Future<void> Function() shutdown;

  @override
  State<_ActivatedPhase3App> createState() =>
      _ActivatedPhase3AppState();
}

final class _ActivatedPhase3AppState extends State<_ActivatedPhase3App> {
  RecoveryDirective? _dismissedRecovery;
  int _shellGeneration = 0;

  @override
  void dispose() {
    unawaited(widget.shutdown());
    super.dispose();
  }

  void _resumeFromSafeState(RecoveryDirective directive) {
    setState(() {
      _dismissedRecovery = directive;
      _shellGeneration += 1;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: _productionUi.showDebugBanner,
        title: _productionUi.appName,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
        ),
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: AgentUIBridgeBuilder(
          bridge: widget.bridge,
          builder: (context, uiState) {
            final candidate = uiState.recovery;
            final directive = candidate != null &&
                    candidate.mode == RecoveryMode.safeShell &&
                    !identical(candidate, _dismissedRecovery)
                ? candidate
                : null;
            if (directive != null) {
              return _RecoverySafeHome(
                directive: directive,
                onResume: () => _resumeFromSafeState(directive),
              );
            }
            return LocalLearningRecoveryRuntimeHost(
              repository: widget.learnerRepository,
              preferences: widget.preferences,
              corpus: widget.corpus,
              child: Phase3ProductionShell(
                key: ValueKey<int>(_shellGeneration),
                corpus: widget.corpus,
                startTaskOrder: widget.startTaskOrder,
              ),
            );
          },
        ),
      );
}

final class _RecoverySafeHome extends StatelessWidget {
  const _RecoverySafeHome({
    required this.directive,
    required this.onResume,
  });

  final RecoveryDirective directive;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الوضع الآمن')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.health_and_safety_outlined,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'تم تأمين التطبيق',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        directive.userMessage,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'السياق: ${directive.context}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: onResume,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('العودة إلى الواجهة الآمنة'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

final class _InlineSafeError extends StatelessWidget {
  const _InlineSafeError();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Icon(Icons.error_outline, size: 48),
              SizedBox(height: 12),
              Text('تعذر عرض هذا الجزء بأمان.'),
              SizedBox(height: 6),
              Text('بقية التطبيق محمية ويمكنك الرجوع أو إعادة المحاولة.'),
            ],
          ),
        ),
      );
}

final class _BootFailureApp extends StatelessWidget {
  const _BootFailureApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: _productionUi.showDebugBanner,
        title: _productionUi.appName,
        home: Scaffold(
          appBar: AppBar(title: const Text('Salim')),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.error_outline, size: 48),
                  SizedBox(height: 12),
                  Text('تعذر تشغيل التطبيق بأمان. لم يتم حذف بياناتك.'),
                  SizedBox(height: 8),
                  Text(
                    'أغلق التطبيق وأعد فتحه. إذا استمرت المشكلة، تحقق من مساحة التخزين.',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
