import 'dart:async';

import 'orchestration_models.dart';

final class AgentEventBus {
  AgentEventBus()
      : _transport = _applicationTransport,
        _ownsTransport = false;

  AgentEventBus.isolated()
      : _transport = _EventTransport(),
        _ownsTransport = true;

  static final _EventTransport _applicationTransport = _EventTransport();

  final _EventTransport _transport;
  final bool _ownsTransport;
  int _sequence = 0;
  bool _closed = false;

  int get publishedCount => _sequence;
  int get pairEpoch => _transport.pairEpoch;
  int get droppedStaleCount => _transport.droppedStaleCount;
  bool get isClosed => _closed;
  bool get usesApplicationTransport => !_ownsTransport;

  AgentEvent publish({
    required AgentDescriptor source,
    required String topic,
    required Map<String, Object?> payload,
    required AgentContextSnapshot context,
    Set<AgentRole> targetRoles = const <AgentRole>{},
  }) {
    if (_closed) {
      throw StateError('Cannot publish to a closed AgentEventBus.');
    }

    final normalizedTopic = topic.trim().toLowerCase();
    var stampedContext = context;

    if (normalizedTopic == AgentTopics.localizationChangeRequested) {
      if (context.pairEpoch != 0 && context.pairEpoch != _transport.pairEpoch) {
        return _dropStale(
          source: source,
          topic: normalizedTopic,
          payload: payload,
          context: context,
          targetRoles: targetRoles,
        );
      }
      _transport.pairEpoch += 1;
      stampedContext = context.withTemporal(pairEpoch: _transport.pairEpoch);
    } else {
      final eventEpoch =
          context.pairEpoch == 0 ? _transport.pairEpoch : context.pairEpoch;
      stampedContext = context.withTemporal(pairEpoch: eventEpoch);
      if (eventEpoch != _transport.pairEpoch) {
        return _dropStale(
          source: source,
          topic: normalizedTopic,
          payload: payload,
          context: stampedContext,
          targetRoles: targetRoles,
        );
      }
    }

    final sequence = ++_sequence;
    if (stampedContext.generation == 0) {
      stampedContext = stampedContext.withTemporal(generation: sequence);
    }

    final event = AgentEvent(
      sequence: sequence,
      topic: normalizedTopic,
      sourceAgentId: source.id,
      sourceRole: source.role,
      targetRoles: targetRoles,
      context: stampedContext,
      payload: payload,
    );
    _transport.add(event);
    return event;
  }

  Stream<AgentEvent> eventsFor(
    AgentDescriptor subscriber,
    String topic,
  ) {
    final normalizedTopic = topic.trim().toLowerCase();
    if (!subscriber.subscribesTo(normalizedTopic)) {
      return const Stream<AgentEvent>.empty();
    }

    return _transport.stream.where(
      (event) =>
          event.topic == normalizedTopic &&
          event.sourceAgentId != subscriber.id &&
          (event.isAddressedTo(subscriber.role) ||
              subscriber.observesTargetedEvents),
    );
  }

  Stream<AgentEvent> allEventsFor(AgentDescriptor subscriber) =>
      _transport.stream.where(
        (event) =>
            event.sourceAgentId != subscriber.id &&
            subscriber.subscribesTo(event.topic) &&
            (event.isAddressedTo(subscriber.role) ||
                subscriber.observesTargetedEvents),
      );

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    if (_ownsTransport) {
      await _transport.close();
    }
  }

  AgentEvent _dropStale({
    required AgentDescriptor source,
    required String topic,
    required Map<String, Object?> payload,
    required AgentContextSnapshot context,
    required Set<AgentRole> targetRoles,
  }) {
    _transport.droppedStaleCount += 1;
    final sequence = ++_sequence;
    final stamped = context.generation == 0
        ? context.withTemporal(generation: sequence)
        : context;
    return AgentEvent(
      sequence: sequence,
      topic: topic,
      sourceAgentId: source.id,
      sourceRole: source.role,
      targetRoles: targetRoles,
      context: stamped,
      payload: payload,
    );
  }
}

final class _EventTransport {
  final StreamController<AgentEvent> _controller =
      StreamController<AgentEvent>.broadcast(sync: true);
  int pairEpoch = 0;
  int droppedStaleCount = 0;
  bool _closed = false;

  Stream<AgentEvent> get stream => _controller.stream;

  void add(AgentEvent event) {
    if (_closed) {
      throw StateError('Cannot publish to a closed event transport.');
    }
    _controller.add(event);
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _controller.close();
  }
}
