import 'dart:async';

import '../orchestration/orchestration.dart';
import 'memory_models.dart';
import 'sys_error_recovery_fallback.dart';
import 'sys_memory_agent.dart';

final class SystemAgentRuntime {
  SystemAgentRuntime._({
    required AgentEventBus eventBus,
    required OrchestrationKernel kernel,
    required AgentEndpoint systemEndpoint,
    required SysMemoryAgent memoryAgent,
    required SysErrorRecoveryFallback recoveryAgent,
  })  : _eventBus = eventBus,
        _kernel = kernel,
        _systemEndpoint = systemEndpoint,
        _memoryAgent = memoryAgent,
        _recoveryAgent = recoveryAgent;

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

    final memoryAgent = await SysMemoryAgent.start(
      endpoint: memoryEndpoint,
      store: memoryStore,
    );
    final recoveryAgent = SysErrorRecoveryFallback.start(
      endpoint: recoveryEndpoint,
    );

    return SystemAgentRuntime._(
      eventBus: eventBus,
      kernel: kernel,
      systemEndpoint: systemEndpoint,
      memoryAgent: memoryAgent,
      recoveryAgent: recoveryAgent,
    );
  }

  final AgentEventBus _eventBus;
  final OrchestrationKernel _kernel;
  final AgentEndpoint _systemEndpoint;
  final SysMemoryAgent _memoryAgent;
  final SysErrorRecoveryFallback _recoveryAgent;

  int _sequence = 0;
  bool _closed = false;

  bool get isClosed => _closed;
  int get publishedEventCount => _eventBus.publishedCount;
  MemoryAgentSnapshot get memorySnapshot => _memoryAgent.snapshot;

  Stream<RecoveryDirective> get recoveryDirectives =>
      _systemEndpoint
          .events(AgentTopics.systemRecovery)
          .map(RecoveryDirective.fromEvent);

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
        'message': _boundedText(message, 240, 'Unexpected application error'),
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
    await _memoryAgent.close();
    await _recoveryAgent.close();
    await _kernel.close();
  }

  String _nextCorrelation(String purpose) {
    _sequence += 1;
    return 'sys.$purpose.$_sequence';
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('SystemAgentRuntime is closed.');
    }
  }
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
