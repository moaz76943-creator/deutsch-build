import 'dart:async';

import 'orchestration_models.dart';

final class AgentEventBus {
  AgentEventBus()
      : _controller = StreamController<AgentEvent>.broadcast(sync: true);

  final StreamController<AgentEvent> _controller;
  int _sequence = 0;
  bool _closed = false;

  int get publishedCount => _sequence;
  bool get isClosed => _closed;

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
    _controller.add(event);
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

    return _controller.stream.where(
      (event) =>
          event.topic == normalizedTopic &&
          event.sourceAgentId != subscriber.id &&
          event.isAddressedTo(subscriber.role),
    );
  }

  Stream<AgentEvent> allEventsFor(AgentDescriptor subscriber) =>
      _controller.stream.where(
        (event) =>
            event.sourceAgentId != subscriber.id &&
            subscriber.subscribesTo(event.topic) &&
            event.isAddressedTo(subscriber.role),
      );

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _controller.close();
  }
}
