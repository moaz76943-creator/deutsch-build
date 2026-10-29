import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'core/agents/agents.dart';
import 'core/content_contract.dart';
import 'core/explainer/explainer.dart';
import 'core/quick_review/quick_review.dart';
import 'core/curriculum/canonical_curriculum_50.dart';
import 'core/curriculum/curriculum_models.dart';
import 'core/infrastructure/audio/flutter_tts_audio_engine.dart';
import 'features/audio/data/android_recorded_audio_player.dart';
import 'features/audio/data/audio_manifest_catalog.dart';
import 'features/audio/domain/services/i_audio_runtime.dart';
import 'features/audio/offline_audio_runtime.dart';
import 'features/grammar/data/ar_de_grammar_explain_why.dart';
import 'features/gamification/data/android_gamification_clock_integrity_source.dart';
import 'features/gamification/gamification_repository.dart';
import 'features/gamification/sqlite_gamification_repository.dart';
import 'features/learning/data/local_learning_recovery_pair_progress_lease.dart';
import 'features/learning/presentation/local_learning_recovery_runtime_host.dart';
import 'features/placement/application/placement_test_notifier.dart';
import 'features/placement/data/learner_placement_profile_repository.dart';
import 'features/placement/data/local_placement_repository.dart';
import 'features/placement/data/placement_audio_runtime_adapter.dart';
import 'features/placement/presentation/placement_test_screen.dart';
import 'language/german/german_language_pack.dart';
import 'language/german/german_speech_profile.dart';
import 'models/content.dart';
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

  ErrorWidget.builder = (FlutterErrorDetails details) => const Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          child: _InlineSafeError(),
        ),
      );

  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    runtimeFailureReporter.record(
      error,
      stack,
      fatal: true,
      context: 'root_isolate',
    );
    unawaited(
      _dispatchRecoveryError(
        error: error,
        context: 'root_isolate',
        fatal: true,
      ),
    );
    return true;
  };

  try {
    _verifyProductionContract();
    runApp(const _RenderFirstBootstrapApp());
  } catch (error, stack) {
    runtimeFailureReporter.record(
      error,
      stack,
      fatal: true,
      context: 'bootstrap',
    );
    unawaited(
      _dispatchRecoveryError(
        error: error,
        context: 'bootstrap',
        fatal: true,
      ),
    );
    runApp(const _BootFailureApp());
  }
}

void _registerProjectOpenSourceLicensesSafely() {
  try {
    registerProjectOpenSourceLicenses();
  } on Object catch (error) {
    unawaited(
      _dispatchRecoveryError(
        error: error,
        context: 'license_registry',
        fatal: false,
      ),
    );
  }
}

Future<_ActivatedPhase3App> _activateProduction({
  required PreferencesService prefs,
  required LearnerRepository learnerRepository,
  required GamificationRepository gamificationRepository,
}) async {
  final systemAgents = await SystemAgentRuntime.start(
    memoryStore: _PreferencesMemoryAgentStore(prefs),
  );
  _systemAgentRuntime = systemAgents;
  LocalLearningRecoveryPairProgressLease? recoveryPairProgress;
  _ResolvedCorpusSession? corpusSession;
  IAudioRuntime? activatedAudioRuntime;

  try {
    const activeLanguagePack = GermanLanguagePack();
    final audioCatalogFuture = _loadGermanAudioCatalog();
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
    final resolvedCorpusSession =
        await _resolveActiveCorpusSession(prefs);
    corpusSession = resolvedCorpusSession;
    final indexedCorpus = resolvedCorpusSession.resolution.corpusRepository;
    if (indexedCorpus == null) {
      throw StateError('indexed_corpus_unavailable_for_v11_ui');
    }
    final quickReviewService =
        QuickReviewBindings.fromIndexedSrsCorpus(indexedCorpus);
    final explainWhyEngine = await ArDeGrammarExplainWhyCatalog.load(
      readText: rootBundle.loadString,
    );
    final explainerService = ExplainerBindings.fromIndexedSrsCorpus(
      indexedCorpus,
      explainWhyEngine: explainWhyEngine,
    );
    final uiBridge = AgentUIBridge.attach(systemAgents);
    final routeState = await learnerRepository.reloadPersisted();
    final audioRuntime = OfflineAudioRuntime(
      speechProfile: activeLanguagePack.speechProfile,
      ttsEngine: FlutterOfflineTtsEngine(),
      catalog: await audioCatalogFuture,
      recordedPlayer: AndroidRecordedAudioPlayer(),
    );
    activatedAudioRuntime = audioRuntime;

    return _ActivatedPhase3App(
      corpus: resolvedCorpusSession.initialCorpus,
      audioRuntime: audioRuntime,
      bridge: uiBridge,
      preferences: prefs,
      learnerRepository: learnerRepository,
      gamificationRepository: gamificationRepository,
      quickReviewService: quickReviewService,
      explainerService: explainerService,
      reviewSourceLanguageCode: activeLanguagePack.languageCode,
      reviewTranslationLanguageCode: activeLanguagePack.sourceLocale,
      startTaskOrder: _placementStartTaskOrder(routeState),
      shutdown: () async {
        await audioRuntime.shutdown();
        await resolvedCorpusSession.resolution.closeCorpus();
        await resolvedCorpusSession.resolution.grammarHubService.close();
        await recoveryPairProgress?.close();
        await gamificationRepository.close();
        await _shutdownActivatedRuntime(
          runtime: systemAgents,
          bridge: uiBridge,
        );
      },
    );
  } catch (_) {
    final audio = activatedAudioRuntime;
    if (audio != null) {
      try {
        await audio.shutdown();
      } on Object {
        // Preserve the original activation failure.
      }
    }
    final session = corpusSession;
    if (session != null) {
      try {
        await session.resolution.closeCorpus();
        await session.resolution.grammarHubService.close();
      } on Object {
        // Preserve the original activation failure.
      }
    }
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

Future<AudioManifestCatalog> _loadGermanAudioCatalog() async {
  try {
    final raw = await rootBundle.loadString(
      'content/german/audio_manifest.json',
    );
    return AudioManifestCatalog.parse(raw);
  } on Object {
    return AudioManifestCatalog.empty();
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

final class _ResolvedCorpusSession {
  const _ResolvedCorpusSession({
    required this.resolution,
    required this.initialCorpus,
  });

  final RuntimePackResolution resolution;
  final List<LearningContent> initialCorpus;
}

Future<_ResolvedCorpusSession> _resolveActiveCorpusSession(
  PreferencesService prefs,
) async {
  const initialWindowSize = 128;

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

  final repository = resolution.corpusRepository;
  if (repository == null) {
    await resolution.grammarHubService.close();
    throw StateError(
      'indexed_corpus_unavailable:'
      '${resolution.state.fallbackReason ?? 'unknown'}',
    );
  }

  final verification = repository.verification;
  if (!verification.hasExpectedCardinality) {
    await resolution.closeCorpus();
    await resolution.grammarHubService.close();
    throw StateError('indexed_corpus_cardinality_mismatch');
  }

  final page = await repository.fetchPage(
    limit: initialWindowSize,
  );
  if (page.isEmpty) {
    await resolution.closeCorpus();
    await resolution.grammarHubService.close();
    throw StateError('indexed_corpus_initial_window_empty');
  }

  final initialCorpus = page
      .map(
        (item) => ContentItem(
          id: item.id,
          german: item.german,
          arabic: item.arabic,
          sentence: item.sentence,
          sentenceAr: item.sentenceAr,
          topic: item.topic,
          skill: item.skill,
          article: item.article,
          plural: item.plural,
          accepted: item.accepted,
        ),
      )
      .cast<LearningContent>()
      .toList(growable: false);

  return _ResolvedCorpusSession(
    resolution: resolution,
    initialCorpus: List<LearningContent>.unmodifiable(initialCorpus),
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

  final PreferencesService preferences;

  @override
  Future<String?> read() async =>
      preferences.readSystemMemoryAgentState();

  @override
  Future<void> write(String encoded) async {
    final written =
        await preferences.writeSystemMemoryAgentState(encoded);
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

final class _RenderFirstBootstrapApp extends StatefulWidget {
  const _RenderFirstBootstrapApp();

  @override
  State<_RenderFirstBootstrapApp> createState() =>
      _RenderFirstBootstrapAppState();
}

final class _RenderFirstBootstrapAppState
    extends State<_RenderFirstBootstrapApp> {
  Widget? _resolved;
  bool _loading = false;
  Object? _bootstrapError;
  String _bootstrapStatus = 'جاري تجهيز التطبيق المحلي…';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registerProjectOpenSourceLicensesSafely();
      unawaited(_bootstrap());
    });
  }

  void _updateBootstrapStatus(String status) {
    if (!mounted) return;
    setState(() => _bootstrapStatus = status);
  }

  Future<void> _bootstrap() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _bootstrapError = null;
      _bootstrapStatus = 'جاري تجهيز الإعدادات المحلية…';
    });

    GamificationRepository? gamificationRepository;
    try {
      final prefs = await PreferencesService.instance();
      _updateBootstrapStatus('جاري فتح بيانات التقدم المحلية…');
      final databaseRoot = await getDatabasesPath();
      final openedGamificationRepository =
          await SqliteGamificationRepository.open(
        p.join(databaseRoot, 'gamification.sqlite'),
        clockIntegritySource:
            const AndroidGamificationClockIntegritySource(),
      );
      gamificationRepository = openedGamificationRepository;
      final learnerRepository = LearnerRepository(
        prefs,
        persistence: LearnerPersistence(
          prefs,
          LearnerRepository.key,
          LearnerRepository.legacyFavoriteKey,
        ),
        gamificationReviewSink: openedGamificationRepository,
      );
      final state = learnerRepository.load();
      Attempt? legacyLastReview;
      for (final attempt in state.attempts) {
        if (legacyLastReview == null ||
            attempt.at.isAfter(legacyLastReview.at)) {
          legacyLastReview = attempt;
        }
      }
      await openedGamificationRepository.migrateLegacyProfileIfPristine(
        totalXp: state.xp,
        currentStreak: state.streak,
        lastReviewAtUtc: legacyLastReview?.at.toUtc(),
        timezoneOffsetMinutes:
            legacyLastReview?.at.timeZoneOffset.inMinutes,
      );

      late final Widget next;
      if (_needsPlacementOnboarding(state)) {
        _updateBootstrapStatus('جاري تجهيز اختبار تحديد المستوى…');
        next = _PlacementBootstrapApp(
          prefs: prefs,
          learnerRepository: learnerRepository,
          gamificationRepository: openedGamificationRepository,
        );
      } else {
        _updateBootstrapStatus('جاري تجهيز محرك التعلم المحلي…');
        next = await _activateProduction(
          prefs: prefs,
          learnerRepository: learnerRepository,
          gamificationRepository: openedGamificationRepository,
        );
      }

      if (!mounted) {
        if (next is _ActivatedPhase3App) {
          await next.shutdown();
        } else {
          await openedGamificationRepository.close();
        }
        return;
      }
      setState(() {
        _resolved = next;
        _loading = false;
      });
    } catch (error) {
      await gamificationRepository?.close();
      await _dispatchRecoveryError(
        error: error,
        context: 'render_first.bootstrap',
        fatal: false,
      );
      if (!mounted) return;
      setState(() {
        _bootstrapError = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolved;
    if (resolved != null) return resolved;

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
      home: _bootstrapError == null
          ? _RenderFirstLoading(status: _bootstrapStatus)
          : _RenderFirstFailure(
              onRetry: () => unawaited(_bootstrap()),
            ),
    );
  }
}

final class _RenderFirstLoading extends StatelessWidget {
  const _RenderFirstLoading({
    this.status = 'جاري تجهيز التطبيق المحلي…',
  });

  final String status;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.school_rounded,
                    size: 54,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Deutsch بالعربي',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const SizedBox.square(
                    dimension: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    status,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

final class _RenderFirstFailure extends StatelessWidget {
  const _RenderFirstFailure({
    required this.onRetry,
  });

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
                  const Icon(Icons.storage_rounded, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'تعذر فتح المحتوى المحلي الموثق.',
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

final class _PlacementBootstrapApp extends StatefulWidget {
  const _PlacementBootstrapApp({
    required this.prefs,
    required this.learnerRepository,
    required this.gamificationRepository,
  });

  final PreferencesService prefs;
  final LearnerRepository learnerRepository;
  final GamificationRepository gamificationRepository;

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
      speechProfile: GermanSpeechProfile(),
      ttsEngine: FlutterOfflineTtsEngine(),
    );
    _notifier = PlacementTestNotifier(
      repository: LocalPlacementRepository(),
      profileRepository:
          LearnerPlacementProfileRepository(widget.learnerRepository),
      audioGateway: PlacementAudioRuntimeAdapter(_placementAudio),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    unawaited(_closePlacementAudio());
    if (_activated == null) {
      unawaited(widget.gamificationRepository.close());
    }
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
        gamificationRepository: widget.gamificationRepository,
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
    required this.audioRuntime,
    required this.bridge,
    required this.preferences,
    required this.learnerRepository,
    required this.gamificationRepository,
    required this.quickReviewService,
    required this.explainerService,
    required this.reviewSourceLanguageCode,
    required this.reviewTranslationLanguageCode,
    required this.startTaskOrder,
    required this.shutdown,
  });

  final List<LearningContent> corpus;
  final IAudioRuntime audioRuntime;
  final AgentUIBridge bridge;
  final PreferencesService preferences;
  final LearnerRepository learnerRepository;
  final GamificationRepository gamificationRepository;
  final QuickReviewService quickReviewService;
  final ExplainerService explainerService;
  final String reviewSourceLanguageCode;
  final String reviewTranslationLanguageCode;
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
                audioRuntime: widget.audioRuntime,
                learnerRepository: widget.learnerRepository,
                gamificationRepository: widget.gamificationRepository,
                quickReviewService: widget.quickReviewService,
                explainerService: widget.explainerService,
                reviewSourceLanguageCode: widget.reviewSourceLanguageCode,
                reviewTranslationLanguageCode:
                    widget.reviewTranslationLanguageCode,
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
