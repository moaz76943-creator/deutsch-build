import 'agent_batch_processing.dart';
import 'event_bus.dart';
import 'orchestration_models.dart';
import 'service_container.dart';

final class AgentEndpoint implements AgentReferenceBoundary {
  AgentEndpoint._({
    required this.descriptor,
    required AgentEventBus eventBus,
    required ServiceContainer services,
  })  : _eventBus = eventBus,
        _services = services;

  final AgentDescriptor descriptor;
  final AgentEventBus _eventBus;
  final ServiceContainer _services;
  bool _active = true;
  int _emittedCount = 0;

  bool get isActive => _active;

  Stream<AgentEvent> events(String topic) {
    _ensureActive();
    return _eventBus.eventsFor(descriptor, topic);
  }

  Stream<AgentEvent> get allEvents {
    _ensureActive();
    return _eventBus.allEventsFor(descriptor);
  }

  AgentEvent publish({
    required String topic,
    required Map<String, Object?> payload,
    AgentContextSnapshot? context,
    Set<AgentRole> targetRoles = const <AgentRole>{},
  }) {
    _ensureActive();
    _emittedCount += 1;
    final snapshot = context ??
        AgentContextSnapshot.empty(
          '${descriptor.id}:event-$_emittedCount',
        );
    return _eventBus.publish(
      source: descriptor,
      topic: topic,
      payload: payload,
      context: snapshot,
      targetRoles: targetRoles,
    );
  }

  AgentEventBatchDispatcher createBatchDispatcher({
    int maxBatchSize = 16,
    int maxPending = 256,
    Duration flushDelay = const Duration(milliseconds: 2),
  }) {
    _ensureActive();
    return AgentEventBatchDispatcher(
      currentPairEpoch: () => _eventBus.pairEpoch,
      queue: AgentBatchQueue<AgentBatchEvent>(
        maxBatchSize: maxBatchSize,
        maxPending: maxPending,
        flushDelay: flushDelay,
        dedupeKeyOf: (event) => event.dedupeKey,
        processBatch: (events) async {
          verifyGuardedAgentBatch(events);
          for (final event in events) {
            publish(
              topic: event.topic,
              payload: event.payload,
              context: event.context,
              targetRoles: event.targetRoles,
            );
          }
          await Future<void>.delayed(Duration.zero);
        },
      ),
    );
  }

  T resolve<T>(ServiceToken<T> token) {
    _ensureActive();
    return _services.resolve(token);
  }

  void _deactivate() {
    _active = false;
  }

  void _ensureActive() {
    if (!_active) {
      throw StateError('Agent endpoint ${descriptor.id} is inactive.');
    }
  }
}

final class OrchestrationKernel {
  OrchestrationKernel({
    required AgentEventBus eventBus,
    required ServiceContainer services,
  })  : _eventBus = eventBus,
        _services = services;

  final AgentEventBus _eventBus;
  final ServiceContainer _services;
  final Map<String, AgentEndpoint> _endpoints = <String, AgentEndpoint>{};
  bool _closed = false;

  int get connectedAgentCount => _endpoints.length;
  bool get isClosed => _closed;

  AgentEndpoint connect(AgentDescriptor descriptor) {
    if (_closed) {
      throw StateError('Cannot connect agents to a closed kernel.');
    }
    if (_endpoints.containsKey(descriptor.id)) {
      throw StateError('Agent id already connected: ${descriptor.id}.');
    }

    if (!_services.isFrozen) {
      _services.freeze();
    }

    final endpoint = AgentEndpoint._(
      descriptor: descriptor,
      eventBus: _eventBus,
      services: _services,
    );
    _endpoints[descriptor.id] = endpoint;
    return endpoint;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    for (final endpoint in _endpoints.values) {
      endpoint._deactivate();
    }
    _endpoints.clear();
    await _eventBus.close();
  }
}
