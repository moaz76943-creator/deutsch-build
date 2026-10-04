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

    final event = AgentEvent(
      sequence: ++_sequence,
      topic: topic,
      sourceAgentId: source.id,
      sourceRole: source.role,
      targetRoles: targetRoles,
      context: context,
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
}

final class _EventTransport {
  final StreamController<AgentEvent> _controller =
      StreamController<AgentEvent>.broadcast(sync: true);
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
