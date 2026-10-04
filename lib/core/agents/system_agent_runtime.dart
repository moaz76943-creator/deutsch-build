import 'dart:async';

import '../orchestration/orchestration.dart';
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
  })  : _eventBus = eventBus,
        _kernel = kernel,
        _systemEndpoint = systemEndpoint,
        _memoryAgent = memoryAgent,
        _recoveryAgent = recoveryAgent,
        _polyglotAgent = polyglotAgent,
        _grammarAgent = grammarAgent,
        _voiceAgent = voiceAgent;

  static Future<SystemAgentRuntime> start({
    required MemoryAgentStore memoryStore,
  }) async {
    final eventBus = AgentEventBus();
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
          AgentTopics.polyglotMatrixChanged,
          AgentTopics.grammarEngineChanged,
          AgentTopics.grammarResponse,
          AgentTopics.ttsPrepared,
          AgentTopics.ttsCompleted,
          AgentTopics.ttsFailed,
        },
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
      store: memoryStore,
    );
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

    return SystemAgentRuntime._(
      eventBus: eventBus,
      kernel: kernel,
      systemEndpoint: systemEndpoint,
      memoryAgent: memoryAgent,
      recoveryAgent: recoveryAgent,
      polyglotAgent: polyglotAgent,
      grammarAgent: grammarAgent,
      voiceAgent: voiceAgent,
    );
  }

  final AgentEventBus _eventBus;
  final OrchestrationKernel _kernel;
  final AgentEndpoint _systemEndpoint;
  final SysMemoryAgent _memoryAgent;
  final SysErrorRecoveryFallback _recoveryAgent;
  final SysPolyglotMatrixAgent _polyglotAgent;
  final SysUniversalGrammarAgent _grammarAgent;
  final SysTtsVoiceAgent _voiceAgent;

  int _sequence = 0;
  bool _closed = false;

  bool get isClosed => _closed;
  int get publishedEventCount => _eventBus.publishedCount;
  MemoryAgentSnapshot get memorySnapshot => _memoryAgent.snapshot;
  PolyglotMatrixState? get polyglotMatrixState => _polyglotAgent.state;
  String? get activeGrammarEngineId => _grammarAgent.activeEngineId;

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

    _systemEndpoint.publish(
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
  }

  Future<GrammarAgentResult> requestGrammar({
    required UniversalGrammarCapability capability,
    int seed = 0,
    int count = 6,
  }) async {
    _ensureOpen();
    final boundedCount = count.clamp(1, 20).toInt();
    final correlationId = _nextCorrelation('grammar');
    final response = _systemEndpoint
        .events(AgentTopics.grammarResponse)
        .firstWhere(
          (event) => event.context.correlationId == correlationId,
        )
        .timeout(const Duration(seconds: 2));

    _systemEndpoint.publish(
      topic: AgentTopics.grammarRequest,
      targetRoles: const <AgentRole>{AgentRole.grammar},
      context: AgentContextSnapshot.empty(correlationId),
      payload: <String, Object?>{
        'capability': capability.wireName,
        'seed': seed,
        'count': boundedCount,
      },
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
    int? occurredAtEpochMs,
  }) {
    _ensureOpen();
    _systemEndpoint.publish(
      topic: AgentTopics.learningProgress,
      targetRoles: const <AgentRole>{AgentRole.memory},
      context: AgentContextSnapshot.empty(_nextCorrelation('progress')),
      payload: <String, Object?>{
        'taskId': taskId.trim(),
        'score': score.clamp(0.0, 1.0).toDouble(),
        'completed': completed,
        'attempts': attempts.clamp(0, 1000000).toInt(),
        'occurredAtEpochMs':
            occurredAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void recordMistake({
    required String taskId,
    required String weaknessKey,
    int weight = 1,
    int? occurredAtEpochMs,
  }) {
    _ensureOpen();
    _systemEndpoint.publish(
      topic: AgentTopics.learningMistake,
      targetRoles: const <AgentRole>{AgentRole.memory},
      context: AgentContextSnapshot.empty(_nextCorrelation('mistake')),
      payload: <String, Object?>{
        'taskId': taskId.trim(),
        'weaknessKey': weaknessKey.trim(),
        'weight': weight.clamp(1, 1000).toInt(),
        'occurredAtEpochMs':
            occurredAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void recordRouteVisit({
    required String taskId,
    String featureKey = 'bootstrap',
    int? occurredAtEpochMs,
  }) {
    _ensureOpen();
    _systemEndpoint.publish(
      topic: AgentTopics.routeSelected,
      targetRoles: const <AgentRole>{AgentRole.memory},
      context: AgentContextSnapshot.empty(_nextCorrelation('route')),
      payload: <String, Object?>{
        'ok': true,
        'featureKey': featureKey.trim(),
        'curriculumTaskId': taskId.trim(),
        'occurredAtEpochMs':
            occurredAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
      },
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

  Future<void> flushMemory() => _memoryAgent.flush();

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _voiceAgent.close();
    await _grammarAgent.close();
    await _polyglotAgent.close();
    await _memoryAgent.close();
    await _recoveryAgent.close();
    await _kernel.close();
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
