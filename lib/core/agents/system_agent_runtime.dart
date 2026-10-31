import 'dart:async';

import '../orchestration/orchestration.dart';
import '../storage/offline_progress_service.dart';
import '../storage/runtime_local_state_container.dart';
import '../storage/validation_hash_cache.dart';
import '../worker/persistent_cpu_worker.dart';
import '../worker/worker_contract.dart';
import 'memory_models.dart';
import 'polyglot_agent_models.dart';
import 'sys_error_recovery_fallback.dart';
import 'sys_memory_agent.dart';
import 'sys_polyglot_matrix_agent.dart';
import 'sys_tts_voice_agent.dart';
import 'sys_universal_grammar_agent.dart';

final class SystemAgentRuntime {
  SystemAgentRuntime._({
    required AgentEventBus eventBus,
    required OrchestrationKernel kernel,
    required AgentEndpoint systemEndpoint,
    required SysMemoryAgent memoryAgent,
    required SysErrorRecoveryFallback recoveryAgent,
    required SysPolyglotMatrixAgent polyglotAgent,
    required SysUniversalGrammarAgent grammarAgent,
    required SysTtsVoiceAgent voiceAgent,
    required RuntimeLocalStateContainer localState,
    required OfflineProgressService progressService,
    required ValidationHashCache validationCache,
    required AgentEventBatchDispatcher batchDispatcher,
    required PersistentCpuWorker cpuWorker,
  })  : _eventBus = eventBus,
        _kernel = kernel,
        _systemEndpoint = systemEndpoint,
        _memoryAgent = memoryAgent,
        _recoveryAgent = recoveryAgent,
        _polyglotAgent = polyglotAgent,
        _grammarAgent = grammarAgent,
        _voiceAgent = voiceAgent,
        _localState = localState,
        _progressService = progressService,
        _validationCache = validationCache,
        _batchDispatcher = batchDispatcher,
        _cpuWorker = cpuWorker;

  static Future<SystemAgentRuntime> start({
    required MemoryAgentStore memoryStore,
  }) async {
    final localState = await RuntimeLocalStateContainer.open(memoryStore);
    final progressService = await OfflineProgressService.open(
      localState.namespace('progress'),
    );
    final validationCache = await ValidationHashCache.open(
      localState.namespace('validation'),
    );

    final eventBus = AgentEventBus();
    final cpuWorker = await PersistentCpuWorker.start(
      initialEpoch: eventBus.pairEpoch,
    );

    try {
      final kernel = OrchestrationKernel(
      eventBus: eventBus,
      services: ServiceContainer(),
    );

    final systemEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'sys.system-bridge',
        role: AgentRole.system,
        subscriptions: const <String>{
          AgentTopics.memorySnapshot,
          AgentTopics.systemRecovery,
          AgentTopics.learningProgress,
          AgentTopics.localizationChangeRequested,
          AgentTopics.polyglotMatrixChanged,
          AgentTopics.grammarEngineChanged,
          AgentTopics.grammarResponse,
          AgentTopics.ttsPrepared,
          AgentTopics.ttsCompleted,
          AgentTopics.ttsFailed,
        },
        observesTargetedEvents: true,
      ),
    );
    final memoryEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'sys.memory-agent',
        role: AgentRole.memory,
        subscriptions: const <String>{
          AgentTopics.routeSelected,
          AgentTopics.learningProgress,
          AgentTopics.learningMistake,
        },
        observesTargetedEvents: true,
      ),
    );
    final recoveryEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'sys.error-recovery-fallback',
        role: AgentRole.recovery,
        subscriptions: const <String>{
          AgentTopics.systemError,
        },
      ),
    );
    final polyglotEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'sys.polyglot-matrix-agent',
        role: AgentRole.polyglot,
        subscriptions: const <String>{
          AgentTopics.localizationChanged,
        },
        observesTargetedEvents: true,
      ),
    );
    final grammarEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'sys.universal-grammar-agent',
        role: AgentRole.grammar,
        subscriptions: const <String>{
          AgentTopics.polyglotMatrixChanged,
          AgentTopics.grammarRequest,
        },
      ),
    );
    final voiceEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'sys.tts-voice-agent',
        role: AgentRole.voice,
        subscriptions: const <String>{
          AgentTopics.polyglotMatrixChanged,
          AgentTopics.ttsRequest,
        },
      ),
    );

    final memoryAgent = await SysMemoryAgent.start(
      endpoint: memoryEndpoint,
      store: localState.namespace('memory'),
      cpuWorker: cpuWorker,
    );
    await progressService.hydrateFromMemory(memoryAgent.snapshot);
    final recoveryAgent = SysErrorRecoveryFallback.start(
      endpoint: recoveryEndpoint,
    );
    final polyglotAgent = SysPolyglotMatrixAgent.start(
      endpoint: polyglotEndpoint,
    );
    final grammarAgent = SysUniversalGrammarAgent.start(
      endpoint: grammarEndpoint,
    );
    final voiceAgent = SysTtsVoiceAgent.start(
      endpoint: voiceEndpoint,
    );
    final batchDispatcher = systemEndpoint.createBatchDispatcher(
      maxBatchSize: 16,
      maxPending: 256,
      flushDelay: const Duration(milliseconds: 2),
    );

    final runtime = SystemAgentRuntime._(
      eventBus: eventBus,
      kernel: kernel,
      systemEndpoint: systemEndpoint,
      memoryAgent: memoryAgent,
      recoveryAgent: recoveryAgent,
      polyglotAgent: polyglotAgent,
      grammarAgent: grammarAgent,
      voiceAgent: voiceAgent,
      localState: localState,
      progressService: progressService,
      validationCache: validationCache,
      batchDispatcher: batchDispatcher,
      cpuWorker: cpuWorker,
    );
    runtime._pairProgressSubscription =
        runtime.polyglotMatrixChanges.listen(runtime._persistActivePair);
    runtime._externalProgressSubscription = systemEndpoint
        .events(AgentTopics.learningProgress)
        .listen(runtime._persistExternalProgress);
    runtime._pairEpochSubscription = systemEndpoint
        .events(AgentTopics.localizationChangeRequested)
        .listen(
          (event) => runtime._cpuWorker.advanceEpoch(
            event.context.pairEpoch,
          ),
        );
      return runtime;
    } on Object {
      await cpuWorker.close();
      rethrow;
    }
  }

  final AgentEventBus _eventBus;
  final OrchestrationKernel _kernel;
  final AgentEndpoint _systemEndpoint;
  final SysMemoryAgent _memoryAgent;
  final SysErrorRecoveryFallback _recoveryAgent;
  final SysPolyglotMatrixAgent _polyglotAgent;
  final SysUniversalGrammarAgent _grammarAgent;
  final SysTtsVoiceAgent _voiceAgent;
  final RuntimeLocalStateContainer _localState;
  final OfflineProgressService _progressService;
  final ValidationHashCache _validationCache;
  final AgentEventBatchDispatcher _batchDispatcher;
  final PersistentCpuWorker _cpuWorker;

  late final StreamSubscription<PolyglotMatrixState>
      _pairProgressSubscription;
  late final StreamSubscription<AgentEvent>
      _externalProgressSubscription;
  late final StreamSubscription<AgentEvent>
      _pairEpochSubscription;

  int _sequence = 0;
  bool _closed = false;

  bool get isClosed => _closed;
  int get publishedEventCount => _eventBus.publishedCount;
  MemoryAgentSnapshot get memorySnapshot => _memoryAgent.snapshot;
  PolyglotMatrixState? get polyglotMatrixState => _polyglotAgent.state;
  String? get activeGrammarEngineId => _grammarAgent.activeEngineId;
  OfflineProgressSnapshot get progressSnapshot => _progressService.snapshot;
  Stream<OfflineProgressSnapshot> get progressChanges =>
      _progressService.changes;
  AgentBatchQueueStats get batchStats => _batchDispatcher.stats;
  int get validationCacheHits => _validationCache.hits;
  int get validationCacheMisses => _validationCache.misses;
  int get validationCacheEntries => _validationCache.entryCount;
  int get pairEpoch => _eventBus.pairEpoch;
  int get workerPendingJobs => _cpuWorker.pendingCount;
  bool get workerClosed => _cpuWorker.isClosed;

  Stream<RecoveryDirective> get recoveryDirectives =>
      _systemEndpoint
          .events(AgentTopics.systemRecovery)
          .map(RecoveryDirective.fromEvent);

  Stream<PolyglotMatrixState> get polyglotMatrixChanges =>
      _systemEndpoint
          .events(AgentTopics.polyglotMatrixChanged)
          .map(PolyglotMatrixState.fromEvent);

  Stream<AgentEvent> get grammarEngineChanges =>
      _systemEndpoint.events(AgentTopics.grammarEngineChanged);

  Stream<GrammarAgentResult> get grammarResponses =>
      _systemEndpoint
          .events(AgentTopics.grammarResponse)
          .map(GrammarAgentResult.fromEvent);

  Stream<TtsVoiceDispatch> get ttsDispatches =>
      _systemEndpoint
          .events(AgentTopics.ttsPrepared)
          .map(TtsVoiceDispatch.fromEvent);

  Stream<AgentEvent> get ttsCompletions =>
      _systemEndpoint.events(AgentTopics.ttsCompleted);

  Stream<AgentEvent> get ttsFailures =>
      _systemEndpoint.events(AgentTopics.ttsFailed);

  void requestLearningPair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
  }) {
    _ensureOpen();
    final source = _requiredLanguageTag(
      sourceLanguageTag,
      'sourceLanguageTag',
    );
    final target = _requiredLanguageTag(
      targetLanguageTag,
      'targetLanguageTag',
    );

    final event = _systemEndpoint.publish(
      topic: AgentTopics.localizationChangeRequested,
      targetRoles: const <AgentRole>{AgentRole.localization},
      context: AgentContextSnapshot.empty(
        _nextCorrelation('language-pair'),
      ),
      payload: <String, Object?>{
        'sourceLocale': source,
        'targetLocale': target,
      },
    );
    _cpuWorker.advanceEpoch(event.context.pairEpoch);
  }

  LanguagePackRepository createLanguagePackRepository({
    required LanguagePackTextLoader loadText,
    String assetRoot = 'assets/lang_data',
  }) {
    _ensureOpen();
    return LanguagePackRepository(
      loadText: loadText,
      assetRoot: assetRoot,
      cpuWorker: _cpuWorker,
    );
  }

  Future<WorkerResult<R>?> dispatchWorkerJob<R>(
    WorkerJob<Object?> job,
  ) async {
    _ensureOpen();
    final result = await _cpuWorker.submit<R>(job);
    if (_closed ||
        result.epoch != pairEpoch ||
        result.status == WorkerStatuses.stale) {
      return null;
    }
    return result;
  }

  Future<WorkerResult<R>?> runCpuJob<R>({
    required String type,
    required Object? payload,
    String? id,
  }) =>
      dispatchWorkerJob<R>(
        WorkerJob<Object?>(
          id: id ?? _nextCorrelation('cpu'),
          type: type,
          epoch: pairEpoch,
          payload: payload,
        ),
      );

  Future<Object?> decodePayload(String encoded) async {
    final result = await runCpuJob<Object>(
      type: WorkerJobTypes.jsonDecode,
      payload: <String, Object?>{'encoded': encoded},
    );
    return _workerPayload(result);
  }

  Future<String?> computeChecksum128({
    required String scopeKey,
    required String content,
    required String validatorVersion,
  }) async {
    final result = await runCpuJob<String>(
      type: WorkerJobTypes.checksum128,
      payload: <String, Object?>{
        'scopeKey': scopeKey,
        'content': content,
        'validatorVersion': validatorVersion,
      },
    );
    return _workerPayload(result);
  }

  Future<String?> computeSha256(String content) async {
    final result = await runCpuJob<String>(
      type: WorkerJobTypes.sha256,
      payload: <String, Object?>{'content': content},
    );
    return _workerPayload(result);
  }

  Future<List<Map<String, Object?>>?> rankFuzzyCandidates({
    required String query,
    required List<Map<String, Object?>> candidates,
    int limit = 20,
  }) async {
    final result = await runCpuJob<Object>(
      type: WorkerJobTypes.fuzzyRank,
      payload: <String, Object?>{
        'query': query,
        'candidates': candidates,
        'limit': limit.clamp(1, 100).toInt(),
      },
    );
    final payload = _workerPayload(result);
    if (payload == null) return null;
    if (payload is! List) {
      throw StateError('CPU worker returned an invalid fuzzy result.');
    }
    return List<Map<String, Object?>>.unmodifiable(
      payload.whereType<Map>().map(
            (row) => Map<String, Object?>.unmodifiable(
              <String, Object?>{
                for (final entry in row.entries)
                  if (entry.key is String)
                    entry.key as String: entry.value,
              },
            ),
          ),
    );
  }

  Future<GrammarAgentResult> requestGrammar({
    required UniversalGrammarCapability capability,
    int seed = 0,
    int count = 6,
  }) async {
    _ensureOpen();
    final boundedCount = count.clamp(1, 20).toInt();
    final correlationId = _nextCorrelation('grammar');
    final matrix = _polyglotAgent.state;
    final sourceLanguage = matrix?.sourceLanguageTag ?? 'und';
    final targetLanguage = matrix?.targetLanguageTag ?? 'und';
    final payload = <String, Object?>{
      'capability': capability.wireName,
      'seed': seed,
      'count': boundedCount,
    };
    final grammarSignature =
        '${capability.wireName}|$seed|$boundedCount|$targetLanguage';
    final validation = await _validationCache.validateOnce(
      scopeKey:
          '${sourceLanguage.toLowerCase()}->'
          '${targetLanguage.toLowerCase()}|grammar|'
          '${capability.wireName}',
      content: grammarSignature,
      validatorVersion: 'runtime.grammar.v1',
      validator: () async {
        final report = const AgentDataIntegrityVerifier().verify(
          <AgentDataRecord>[
            AgentDataRecord(
              recordId: 'validation.$correlationId',
              domain: AgentDataDomain.grammar,
              sourceLanguage: sourceLanguage,
              targetLanguage: targetLanguage,
              canonicalKey: capability.wireName,
              fingerprint: grammarSignature,
            ),
          ],
        );
        return report.isValid;
      },
    );
    if (!validation.validated) {
      throw StateError('Grammar request failed integrity validation.');
    }

    final response = _systemEndpoint
        .events(AgentTopics.grammarResponse)
        .firstWhere(
          (event) => event.context.correlationId == correlationId,
        )
        .timeout(const Duration(seconds: 2));

    await _batchDispatcher.submit(
      AgentBatchEvent(
        dedupeKey: correlationId,
        topic: AgentTopics.grammarRequest,
        context: AgentContextSnapshot.empty(correlationId),
        targetRoles: const <AgentRole>{AgentRole.grammar},
        payload: payload,
        integrityRecord: AgentDataRecord(
          recordId: correlationId,
          domain: AgentDataDomain.grammar,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          canonicalKey: 'runtime.$correlationId',
          fingerprint:
              '${capability.wireName}|$seed|$boundedCount|$targetLanguage',
        ),
      ),
    );

    return GrammarAgentResult.fromEvent(await response);
  }

  Future<TtsVoiceDispatch> prepareSpeech({
    required String text,
    required String targetLanguageTag,
    double speed = 1.0,
  }) async {
    _ensureOpen();
    final request = TtsVoiceRequest(
      text: text,
      targetLanguageTag: targetLanguageTag,
      speed: speed,
    );
    final correlationId = _nextCorrelation('tts');
    final response = _systemEndpoint
        .events(AgentTopics.ttsPrepared)
        .firstWhere(
          (event) => event.context.correlationId == correlationId,
        )
        .timeout(const Duration(seconds: 2));

    _systemEndpoint.publish(
      topic: AgentTopics.ttsRequest,
      targetRoles: const <AgentRole>{AgentRole.voice},
      context: AgentContextSnapshot.empty(correlationId),
      payload: request.toEventPayload(),
    );

    return TtsVoiceDispatch.fromEvent(await response);
  }

  void recordProgress({
    required String taskId,
    required double score,
    required bool completed,
    required int attempts,
    int? points,
    int? occurredAtEpochMs,
  }) {
    _ensureOpen();
    final timestamp =
        occurredAtEpochMs ?? DateTime.now().millisecondsSinceEpoch;
    final normalizedTaskId = taskId.trim();
    final normalizedScore = score.clamp(0.0, 1.0).toDouble();
    final correlationId = _nextCorrelation('progress');

    _submitBackground(
      AgentBatchEvent(
        dedupeKey: correlationId,
        topic: AgentTopics.learningProgress,
        context: AgentContextSnapshot.empty(correlationId),
        targetRoles: const <AgentRole>{AgentRole.memory},
        payload: <String, Object?>{
          'taskId': normalizedTaskId,
          'score': normalizedScore,
          'completed': completed,
          'attempts': attempts.clamp(0, 1000000).toInt(),
          'occurredAtEpochMs': timestamp,
        },
      ),
    );
    _persistBackground(
      _progressService.recordTaskProgress(
        taskId: normalizedTaskId,
        pointsDelta:
            points ?? _defaultProgressPoints(normalizedScore, completed),
        score: normalizedScore,
        completed: completed,
        occurredAtEpochMs: timestamp,
      ),
      context: 'progress.persist',
    );
  }

  void recordMistake({
    required String taskId,
    required String weaknessKey,
    int weight = 1,
    int? occurredAtEpochMs,
  }) {
    _ensureOpen();
    final correlationId = _nextCorrelation('mistake');
    _submitBackground(
      AgentBatchEvent(
        dedupeKey: correlationId,
        topic: AgentTopics.learningMistake,
        context: AgentContextSnapshot.empty(correlationId),
        targetRoles: const <AgentRole>{AgentRole.memory},
        payload: <String, Object?>{
          'taskId': taskId.trim(),
          'weaknessKey': weaknessKey.trim(),
          'weight': weight.clamp(1, 1000).toInt(),
          'occurredAtEpochMs':
              occurredAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
        },
      ),
    );
  }

  void recordRouteVisit({
    required String taskId,
    String featureKey = 'bootstrap',
    int? occurredAtEpochMs,
  }) {
    _ensureOpen();
    final correlationId = _nextCorrelation('route');
    _submitBackground(
      AgentBatchEvent(
        dedupeKey: correlationId,
        topic: AgentTopics.routeSelected,
        context: AgentContextSnapshot.empty(correlationId),
        targetRoles: const <AgentRole>{AgentRole.memory},
        payload: <String, Object?>{
          'ok': true,
          'featureKey': featureKey.trim(),
          'curriculumTaskId': taskId.trim(),
          'occurredAtEpochMs':
              occurredAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
        },
      ),
    );
  }

  Future<RecoveryDirective> reportError({
    required String context,
    required String errorType,
    required String message,
    required bool fatal,
  }) async {
    _ensureOpen();
    final correlationId = _nextCorrelation('error');
    final response = _systemEndpoint
        .events(AgentTopics.systemRecovery)
        .firstWhere(
          (event) => event.context.correlationId == correlationId,
        )
        .timeout(const Duration(seconds: 2));

    _systemEndpoint.publish(
      topic: AgentTopics.systemError,
      targetRoles: const <AgentRole>{AgentRole.recovery},
      context: AgentContextSnapshot.empty(correlationId),
      payload: <String, Object?>{
        'context': _boundedText(context, 120, 'application'),
        'errorType': _boundedText(errorType, 100, 'Error'),
        'message': _boundedText(
          message,
          240,
          'Unexpected application error',
        ),
        'fatal': fatal,
        'occurredAtEpochMs': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return RecoveryDirective.fromEvent(await response);
  }

  Future<ValidationCacheResult> validateContentOnce({
    required String scopeType,
    required String sourceLanguageTag,
    required String targetLanguageTag,
    required String canonicalKey,
    required String content,
    required String validatorVersion,
    required Future<bool> Function() validator,
  }) {
    _ensureOpen();
    final source = _requiredLanguageTag(
      sourceLanguageTag,
      'sourceLanguageTag',
    );
    final target = _requiredLanguageTag(
      targetLanguageTag,
      'targetLanguageTag',
    );
    final scope = '${source.toLowerCase()}->${target.toLowerCase()}'
        '|${scopeType.trim().toLowerCase()}|${canonicalKey.trim()}';
    return _validationCache.validateOnce(
      scopeKey: scope,
      content: content,
      validatorVersion: validatorVersion,
      validator: validator,
    );
  }

  Future<void> flushMemory() async {
    await _batchDispatcher.flush();
    await _memoryAgent.flush();
    await _progressService.flush();
    await _validationCache.flush();
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _pairProgressSubscription.cancel();
    await _externalProgressSubscription.cancel();
    await _pairEpochSubscription.cancel();
    await _batchDispatcher.close();
    await _memoryAgent.flush();
    await _progressService.flush();
    await _validationCache.flush();
    await _voiceAgent.close();
    await _grammarAgent.close();
    await _polyglotAgent.close();
    await _memoryAgent.close();
    await _recoveryAgent.close();
    await _progressService.close();
    await _validationCache.close();
    await _localState.close();
    await _cpuWorker.close();
    await _kernel.close();
  }

  void _persistExternalProgress(AgentEvent event) {
    final taskId = event.payload['taskId'];
    if (taskId is! String || taskId.trim().isEmpty) return;

    final rawScore = event.payload['score'];
    final score =
        rawScore is num ? rawScore.toDouble().clamp(0.0, 1.0) : 0.0;
    final rawPoints = event.payload['points'];
    final points = rawPoints is num
        ? rawPoints.toInt()
        : _defaultProgressPoints(
            score.toDouble(),
            event.payload['completed'] == true,
          );
    final rawTimestamp = event.payload['occurredAtEpochMs'];
    final timestamp = rawTimestamp is num
        ? rawTimestamp.toInt().clamp(0, 4102444800000).toInt()
        : DateTime.now().millisecondsSinceEpoch;

    _persistBackground(
      _progressService.recordTaskProgress(
        taskId: taskId,
        pointsDelta: points,
        score: score.toDouble(),
        completed: event.payload['completed'] == true,
        occurredAtEpochMs: timestamp,
      ),
      context: 'progress.external_event',
    );
  }

  void _persistActivePair(PolyglotMatrixState state) {
    _persistBackground(
      _progressService.setActivePair(
        sourceLanguageTag: state.sourceLanguageTag,
        targetLanguageTag: state.targetLanguageTag,
      ),
      context: 'progress.active_pair',
    );
    _persistBackground(
      _validationCache
          .validateOnce(
            scopeKey:
                '${state.sourceLanguageTag.toLowerCase()}->'
                '${state.targetLanguageTag.toLowerCase()}|pair',
            content:
                '${state.sourceLanguageTag}->${state.targetLanguageTag}',
            validatorVersion: 'runtime.pair.v1',
            validator: () async => true,
          )
          .then<void>((result) {
        if (!result.validated) {
          throw StateError('Language pair validation failed.');
        }
      }),
      context: 'validation.active_pair',
    );
  }

  R? _workerPayload<R>(WorkerResult<R>? result) {
    if (result == null) return null;
    if (result.status != WorkerStatuses.ok) {
      throw StateError(
        'CPU worker failed: ${result.errorCode ?? result.status}.',
      );
    }
    return result.payload;
  }

  static int _defaultProgressPoints(
    double score,
    bool completed,
  ) {
    final scorePoints = (score.clamp(0.0, 1.0) * 100).round();
    final completionBonus = completed ? 25 : 0;
    return (scorePoints + completionBonus).clamp(0, 125).toInt();
  }

  void _submitBackground(AgentBatchEvent event) {
    unawaited(
      _batchDispatcher.submit(event).catchError((Object error) {
        if (_closed) return;
        _publishBackgroundFailure(
          context: 'batch.${event.topic}',
          error: error,
        );
      }),
    );
  }

  void _persistBackground(
    Future<void> operation, {
    required String context,
  }) {
    unawaited(
      operation.catchError((Object error) {
        if (_closed) return;
        _publishBackgroundFailure(
          context: context,
          error: error,
        );
      }),
    );
  }

  void _publishBackgroundFailure({
    required String context,
    required Object error,
  }) {
    _systemEndpoint.publish(
      topic: AgentTopics.systemError,
      targetRoles: const <AgentRole>{AgentRole.recovery},
      context: AgentContextSnapshot.empty(
        _nextCorrelation('background-error'),
      ),
      payload: <String, Object?>{
        'context': _boundedText(context, 120, 'runtime.background'),
        'errorType': error.runtimeType.toString(),
        'message': _boundedText(
          error.toString(),
          240,
          'Background runtime operation failed',
        ),
        'fatal': false,
        'occurredAtEpochMs': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  String _nextCorrelation(String purpose) {
    _sequence += 1;
    return 'sys.' + purpose + '.' + _sequence.toString();
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('SystemAgentRuntime is closed.');
    }
  }
}

String _requiredLanguageTag(String value, String field) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(
      value,
      field,
      'language tag must not be empty',
    );
  }
  return normalized;
}

String _boundedText(
  String value,
  int maxLength,
  String fallback,
) {
  final normalized = value.trim();
  if (normalized.isEmpty) return fallback;
  return normalized.length <= maxLength
      ? normalized
      : normalized.substring(0, maxLength);
}
