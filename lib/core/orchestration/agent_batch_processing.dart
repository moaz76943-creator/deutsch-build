import 'dart:async';
import 'dart:collection';

import 'agent_data_integrity.dart';
import 'orchestration_models.dart';

typedef AgentBatchProcessor<T> = Future<void> Function(List<T> items);
typedef AgentBatchDedupeKey<T> = String Function(T item);

final class AgentBatchQueueStats {
  const AgentBatchQueueStats({
    required this.submitted,
    required this.processed,
    required this.failed,
    required this.coalesced,
    required this.batches,
    required this.maxPendingObserved,
  });

  final int submitted;
  final int processed;
  final int failed;
  final int coalesced;
  final int batches;
  final int maxPendingObserved;
}

final class AgentBatchQueue<T> {
  AgentBatchQueue({
    required this.maxBatchSize,
    required this.maxPending,
    required this.flushDelay,
    required this.dedupeKeyOf,
    required this.processBatch,
  }) {
    if (maxBatchSize < 1 || maxBatchSize > 256) {
      throw ArgumentError.value(
        maxBatchSize,
        'maxBatchSize',
        'must be between 1 and 256',
      );
    }
    if (maxPending < maxBatchSize || maxPending > 10000) {
      throw ArgumentError.value(
        maxPending,
        'maxPending',
        'must be >= maxBatchSize and <= 10000',
      );
    }
    if (flushDelay.isNegative) {
      throw ArgumentError.value(
        flushDelay,
        'flushDelay',
        'must not be negative',
      );
    }
  }

  final int maxBatchSize;
  final int maxPending;
  final Duration flushDelay;
  final AgentBatchDedupeKey<T> dedupeKeyOf;
  final AgentBatchProcessor<T> processBatch;

  final LinkedHashMap<String, _PendingBatchItem<T>> _entries =
      LinkedHashMap<String, _PendingBatchItem<T>>();
  final Queue<String> _order = Queue<String>();

  Timer? _flushTimer;
  Completer<void>? _idleCompleter;
  bool _draining = false;
  bool _accepting = true;

  int _submitted = 0;
  int _processed = 0;
  int _failed = 0;
  int _coalesced = 0;
  int _batches = 0;
  int _maxPendingObserved = 0;

  bool get isClosed => !_accepting;
  int get pendingCount => _entries.length;

  AgentBatchQueueStats get stats => AgentBatchQueueStats(
        submitted: _submitted,
        processed: _processed,
        failed: _failed,
        coalesced: _coalesced,
        batches: _batches,
        maxPendingObserved: _maxPendingObserved,
      );

  Future<void> submit(T item) {
    if (!_accepting) {
      return Future<void>.error(
        StateError('AgentBatchQueue is closed.'),
      );
    }

    final key = dedupeKeyOf(item).trim();
    if (key.isEmpty) {
      return Future<void>.error(
        ArgumentError.value(key, 'dedupeKey', 'must not be empty'),
      );
    }

    final existing = _entries[key];
    if (existing != null) {
      _coalesced += 1;
      return existing.completer.future;
    }

    if (_entries.length >= maxPending) {
      return Future<void>.error(
        StateError(
          'AgentBatchQueue capacity exceeded: $maxPending pending items.',
        ),
      );
    }

    final pending = _PendingBatchItem<T>(item);
    _entries[key] = pending;
    _order.addLast(key);
    _submitted += 1;
    if (_entries.length > _maxPendingObserved) {
      _maxPendingObserved = _entries.length;
    }

    if (_order.length >= maxBatchSize || flushDelay == Duration.zero) {
      _startDrain();
    } else {
      _flushTimer ??= Timer(flushDelay, _startDrain);
    }

    return pending.completer.future;
  }

  Future<void> flush() async {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_order.isEmpty && !_draining) return;

    _startDrain();
    final idle = _idleCompleter;
    if (idle != null) {
      await idle.future;
    }
  }

  Future<void> close() async {
    if (!_accepting) {
      await flush();
      return;
    }
    _accepting = false;
    await flush();
  }

  void _startDrain() {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_draining) return;
    if (_order.isEmpty) {
      _completeIdle();
      return;
    }

    _draining = true;
    _idleCompleter ??= Completer<void>();
    scheduleMicrotask(() async {
      try {
        await _drainLoop();
      } finally {
        _draining = false;
        if (_order.isEmpty) {
          _completeIdle();
        } else {
          _startDrain();
        }
      }
    });
  }

  Future<void> _drainLoop() async {
    while (_order.isNotEmpty) {
      final keys = <String>[];
      while (keys.length < maxBatchSize && _order.isNotEmpty) {
        keys.add(_order.removeFirst());
      }

      final items = <T>[
        for (final key in keys) _entries[key]!.item,
      ];
      _batches += 1;

      try {
        await processBatch(List<T>.unmodifiable(items));
        for (final key in keys) {
          final pending = _entries.remove(key);
          if (pending == null || pending.completer.isCompleted) continue;
          _processed += 1;
          pending.completer.complete();
        }
      } on Object catch (error, stackTrace) {
        for (final key in keys) {
          final pending = _entries.remove(key);
          if (pending == null || pending.completer.isCompleted) continue;
          _failed += 1;
          pending.completer.completeError(error, stackTrace);
        }
      }

      await Future<void>.delayed(Duration.zero);
    }
  }

  void _completeIdle() {
    final idle = _idleCompleter;
    _idleCompleter = null;
    if (idle != null && !idle.isCompleted) {
      idle.complete();
    }
  }
}

final class _PendingBatchItem<T> {
  _PendingBatchItem(this.item);

  final T item;
  final Completer<void> completer = Completer<void>();
}

final class AgentBatchEvent {
  AgentBatchEvent({
    required String dedupeKey,
    required String topic,
    required AgentContextSnapshot context,
    required Set<AgentRole> targetRoles,
    required Map<String, Object?> payload,
    this.integrityRecord,
  })  : dedupeKey = _requiredToken(dedupeKey, 'dedupeKey'),
        topic = _requiredToken(topic, 'topic').toLowerCase(),
        context = context,
        targetRoles = Set<AgentRole>.unmodifiable(targetRoles),
        payload = Map<String, Object?>.unmodifiable(payload);

  final String dedupeKey;
  final String topic;
  final AgentContextSnapshot context;
  final Set<AgentRole> targetRoles;
  final Map<String, Object?> payload;
  final AgentDataRecord? integrityRecord;

  bool get requiresIntegrity =>
      topic == AgentTopics.grammarRequest ||
      topic == AgentTopics.cardsRequest;

  AgentBatchEvent withContext(AgentContextSnapshot nextContext) =>
      AgentBatchEvent(
        dedupeKey: dedupeKey,
        topic: topic,
        context: nextContext,
        targetRoles: targetRoles,
        payload: payload,
        integrityRecord: integrityRecord,
      );
}

final class AgentBatchIntegrityException implements Exception {
  AgentBatchIntegrityException(this.message);

  final String message;

  @override
  String toString() => 'AgentBatchIntegrityException($message)';
}

void verifyGuardedAgentBatch(List<AgentBatchEvent> events) {
  final guarded = events.where((event) => event.requiresIntegrity).toList();
  if (guarded.isEmpty) return;

  for (final event in guarded) {
    if (event.integrityRecord == null) {
      throw AgentBatchIntegrityException(
        'Integrity metadata is required for ${event.topic}.',
      );
    }
  }

  final report = const AgentDataIntegrityVerifier().verify(
    guarded.map((event) => event.integrityRecord!),
  );
  if (!report.isValid) {
    final codes = report.issues
        .map((issue) => issue.code.name)
        .toSet()
        .join(',');
    throw AgentBatchIntegrityException(
      'Batch rejected by data integrity guard: $codes',
    );
  }
}

final class AgentEventBatchDispatcher {
  AgentEventBatchDispatcher({
    required AgentBatchQueue<AgentBatchEvent> queue,
    int Function()? currentPairEpoch,
  })  : _queue = queue,
        _currentPairEpoch = currentPairEpoch ?? _zeroEpoch;

  final AgentBatchQueue<AgentBatchEvent> _queue;
  final int Function() _currentPairEpoch;
  int _generation = 0;

  AgentBatchQueueStats get stats => _queue.stats;
  int get generation => _generation;

  Future<void> submit(AgentBatchEvent event) {
    _generation += 1;
    final context = event.context.withTemporal(
      pairEpoch: event.context.pairEpoch == 0
          ? _currentPairEpoch()
          : event.context.pairEpoch,
      generation: event.context.generation == 0
          ? _generation
          : event.context.generation,
    );
    return _queue.submit(event.withContext(context));
  }

  Future<void> flush() => _queue.flush();

  Future<void> close() => _queue.close();

  static int _zeroEpoch() => 0;
}

String _requiredToken(String value, String field) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
  return normalized;
}
