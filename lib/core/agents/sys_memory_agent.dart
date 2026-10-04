import 'dart:async';

import '../orchestration/orchestration.dart';
import '../worker/persistent_cpu_worker.dart';
import '../worker/worker_contract.dart';
import 'memory_models.dart';

final class SysMemoryAgent {
  SysMemoryAgent._({
    required this.endpoint,
    required this.store,
    required MemoryAgentSnapshot initialSnapshot,
  }) : _snapshot = initialSnapshot;

  static Future<SysMemoryAgent> start({
    required AgentEndpoint endpoint,
    required MemoryAgentStore store,
    required PersistentCpuWorker cpuWorker,
  }) async {
    String? encoded;
    try {
      encoded = await store.read();
    } on Object {
      encoded = null;
    }
    var initial = MemoryAgentSnapshot.empty();
    if (encoded != null && encoded.trim().isNotEmpty) {
      final result = await cpuWorker.submit<Object?>(
        WorkerJob<Map<String, Object?>>(
          id: 'memory.hydrate',
          type: WorkerJobTypes.jsonDecode,
          epoch: cpuWorker.currentEpoch,
          payload: <String, Object?>{'encoded': encoded},
        ),
      );
      if (result.status == WorkerStatuses.ok) {
        initial = MemoryAgentSnapshot.fromDecoded(result.payload);
      }
    }
    final agent = SysMemoryAgent._(
      endpoint: endpoint,
      store: store,
      initialSnapshot: initial,
    );
    agent._subscription = endpoint.allEvents.listen(agent._accept);
    return agent;
  }

  final AgentEndpoint endpoint;
  final MemoryAgentStore store;

  late final StreamSubscription<AgentEvent> _subscription;
  MemoryAgentSnapshot _snapshot;
  Future<void> _writeQueue = Future<void>.value();
  bool _closed = false;

  MemoryAgentSnapshot get snapshot => _snapshot;
  bool get isClosed => _closed;

  void _accept(AgentEvent event) {
    if (_closed) return;
    _writeQueue = _writeQueue
        .catchError((_) {})
        .then((_) async {
          try {
            await _apply(event);
          } on Object {
            return;
          }
        });
  }

  Future<void> _apply(AgentEvent event) async {
    final occurredAtEpochMs = _eventTimestamp(event);

    switch (event.topic) {
      case AgentTopics.routeSelected:
        final ok = event.payload['ok'];
        final taskId = event.payload['curriculumTaskId'];
        if (ok == true && taskId is String && taskId.trim().isNotEmpty) {
          _snapshot = _snapshot.recordVisit(
            taskId,
            occurredAtEpochMs: occurredAtEpochMs,
          );
          await _persistAndPublish();
        }
        return;
      case AgentTopics.learningProgress:
        final taskId = event.payload['taskId'];
        if (taskId is! String || taskId.trim().isEmpty) return;
        final score = _number(event.payload['score']).clamp(0.0, 1.0);
        final attempts = _integer(event.payload['attempts']).clamp(0, 1000000);
        _snapshot = _snapshot.recordProgress(
          rawTaskId: taskId,
          score: score.toDouble(),
          completed: event.payload['completed'] == true,
          attempts: attempts.toInt(),
          occurredAtEpochMs: occurredAtEpochMs,
        );
        await _persistAndPublish();
        return;
      case AgentTopics.learningMistake:
        final taskId = event.payload['taskId'];
        final weaknessKey = event.payload['weaknessKey'];
        if (taskId is! String ||
            taskId.trim().isEmpty ||
            weaknessKey is! String ||
            weaknessKey.trim().isEmpty) {
          return;
        }
        final weight = _integer(event.payload['weight']).clamp(1, 1000);
        _snapshot = _snapshot.recordWeakness(
          rawTaskId: taskId,
          rawWeaknessKey: weaknessKey,
          weight: weight.toInt(),
          occurredAtEpochMs: occurredAtEpochMs,
        );
        await _persistAndPublish();
        return;
    }
  }

  Future<void> _persistAndPublish() async {
    var persisted = true;
    try {
      await store.write(_snapshot.encode());
    } on Object {
      persisted = false;
    }
    endpoint.publish(
      topic: AgentTopics.memorySnapshot,
      targetRoles: const <AgentRole>{AgentRole.system},
      payload: <String, Object?>{
        'taskCount': _snapshot.tasks.length,
        'weaknessCount': _snapshot.weaknesses.length,
        'updatedAtEpochMs': _snapshot.updatedAtEpochMs,
        'persisted': persisted,
      },
    );
  }

  Future<void> flush() => _writeQueue;

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _subscription.cancel();
    await flush();
  }

  static int _eventTimestamp(AgentEvent event) {
    final value = event.payload['occurredAtEpochMs'];
    if (value is num) {
      return value.toInt().clamp(0, 4102444800000).toInt();
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  static double _number(Object? value) =>
      value is num ? value.toDouble() : 0;

  static int _integer(Object? value) =>
      value is num ? value.toInt() : 0;
}
