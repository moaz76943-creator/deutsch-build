import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/agents/agents.dart';
import '../core/content_contract.dart';
import '../core/curriculum/canonical_curriculum_50.dart';
import '../core/curriculum/curriculum_models.dart';
import '../features/audio/data/audio_manifest_catalog.dart';
import '../language/german/german_language_pack.dart';
import '../language/german/bundled_german_pack_downloader.dart';
import '../models/content.dart';
import '../models/learner.dart';
import '../models/pack_security_runtime_config.dart';
import '../services/active_pack_runtime_provider.dart';
import '../services/grammar_hub_service.dart';
import '../services/pack_database_key_store.dart';
import '../services/pack_database_security.dart';
import '../services/pack_manager_service.dart';
import '../services/preferences_service.dart';
import '../ui/bridge/agent_ui_bridge.dart';

final class ProductionRuntimeCoordinator {
  SystemAgentRuntime? _systemAgentRuntime;

  Future<SystemAgentRuntime> startSystemAgents(
    PreferencesService preferences,
  ) async {
    final runtime = await SystemAgentRuntime.start(
      memoryStore: _PreferencesMemoryAgentStore(preferences),
    );
    _systemAgentRuntime = runtime;
    return runtime;
  }

  Future<AudioManifestCatalog> loadGermanAudioCatalog() =>
      _loadGermanAudioCatalog();

  bool needsPlacementOnboarding(
    LearnerState state, {
    required int canonicalXp,
  }) =>
      _needsPlacementOnboarding(
        state,
        canonicalXp: canonicalXp,
      );

  int placementStartTaskOrder(LearnerState state) =>
      _placementStartTaskOrder(state);

  Future<ResolvedCorpusSession> resolveActiveCorpusSession(
    PreferencesService preferences,
  ) =>
      _resolveActiveCorpusSession(preferences);

  Future<void> seedMemoryOnce({
    required SystemAgentRuntime runtime,
    required LearnerState state,
  }) =>
      _seedMemoryOnce(runtime: runtime, state: state);

  Future<void> dispatchRecoveryError({
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

  Future<void> shutdownActivatedRuntime({
    required SystemAgentRuntime runtime,
    required AgentUIBridge bridge,
  }) async {
    await bridge.close();
    await runtime.close();
    if (identical(_systemAgentRuntime, runtime)) {
      _systemAgentRuntime = null;
    }
  }

  Future<void> closeSystemAgents(SystemAgentRuntime runtime) async {
    await runtime.close().catchError((_) {});
    if (identical(_systemAgentRuntime, runtime)) {
      _systemAgentRuntime = null;
    }
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

bool _needsPlacementOnboarding(
  LearnerState state, {
  required int canonicalXp,
}) =>
    state.placementHistory.isEmpty &&
    state.attempts.isEmpty &&
    state.assessmentHistory.isEmpty &&
    state.learned.isEmpty &&
    state.reviewCards.isEmpty &&
    canonicalXp == 0;

int _placementStartTaskOrder(LearnerState state) {
  for (final record in state.placementHistory) {
    if (record.curriculumStartLevel == null) continue;
    return record.recommendedStartTaskOrder.clamp(1, 50).toInt();
  }
  return 1;
}

final class ResolvedCorpusSession {
  const ResolvedCorpusSession({
    required this.resolution,
    required this.initialCorpus,
  });

  final RuntimePackResolution resolution;
  final List<LearningContent> initialCorpus;
}

Future<void> _ensureBundledGermanPackActive(
  PackManagerService manager,
) async {
  if (manager.activePackId == 'de') return;

  if (manager.activePackId != null) {
    throw StateError(
      'A different language pack is active. '
      'Refusing to override the existing selection.',
    );
  }

  if (manager.installedFor('de') != null) {
    await manager.setActivePack('de');
    return;
  }

  final packDirectory = Directory(
    p.join(manager.rootDirectory.path, 'packs', 'de'),
  );

  if (await packDirectory.exists()) {
    throw StateError(
      'Unregistered German pack directory exists. '
      'Manual recovery is required.',
    );
  }

  final rawCatalog = await rootBundle.loadString(
    'assets/content/packs/de/catalog.json',
  );

  final manifest = await manager.loadManifestJson(rawCatalog);
  final descriptor = manifest.packById('de');

  if (descriptor == null) {
    throw StateError('German pack not present in signed catalog.');
  }

  await manager.install(descriptor);

  if (manager.activePackId != 'de') {
    await manager.setActivePack('de');
  }

  if (manager.activePackId != 'de') {
    throw StateError('German pack activation failed.');
  }
}

Future<ResolvedCorpusSession> _resolveActiveCorpusSession(
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
    downloader: const BundledGermanPackDownloader(),
    rootDirectory: Directory(
      p.join(databaseRoot, 'offline_language_packs'),
    ),
  );

  await _ensureBundledGermanPackActive(packManager);

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

  return ResolvedCorpusSession(
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

