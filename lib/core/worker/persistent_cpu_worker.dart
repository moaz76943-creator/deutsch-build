import 'dart:async';
import 'dart:isolate';

import 'package:flutter/widgets.dart';

class WorkerQueueExhaustedException implements Exception {
  const WorkerQueueExhaustedException();
  @override
  String toString() => 'WorkerQueueExhaustedException: queue capacity reached';
}

class WorkerCancelledException implements Exception {
  const WorkerCancelledException();
  @override
  String toString() => 'WorkerCancelledException: generation invalidated';
}

/// Reuses one CPU isolate instead of spawning a new isolate for each review.
/// Job IDs and generation tokens reject late replies after cancellation.
class PersistentCpuWorker with WidgetsBindingObserver {
  PersistentCpuWorker._init();
  static final PersistentCpuWorker instance = PersistentCpuWorker._init();

  static const int defaultMaxQueueSize = 50;
  static const int absoluteMaxQueueSize = 256;
  static const Duration startupTimeout = Duration(seconds: 5);

  final Map<int, Completer<double>> _pending = <int, Completer<double>>{};
  int _maxQueueSize = defaultMaxQueueSize;
  int _nextJobId = 0;
  int _generation = 0;
  int _workerStarts = 0;
  bool _disposed = false;
  bool _observingLifecycle = false;
  Isolate? _isolate;
  SendPort? _commands;
  ReceivePort? _replies;
  Future<SendPort>? _starting;

  int get pendingJobs => _pending.length;
  int get workerStarts => _workerStarts;

  Future<double> calculateNewEaseFactor(double currentEase, int rating) {
    if (_disposed) return Future<double>.error(StateError('Worker disposed'));
    _observeLifecycle();
    if (!currentEase.isFinite || currentEase < 0 || rating < 0 || rating > 5) {
      return Future<double>.error(ArgumentError('Invalid SRS calculation'));
    }
    if (_pending.length >= _maxQueueSize) {
      return Future<double>.error(const WorkerQueueExhaustedException());
    }
    final jobId = ++_nextJobId;
    final completer = Completer<double>();
    _pending[jobId] = completer;
    final generation = _generation;
    _dispatch(jobId, currentEase, rating, generation).catchError(
      (Object error, StackTrace stackTrace) {
        final pending = _pending.remove(jobId);
        if (pending != null && !pending.isCompleted) {
          pending.completeError(error, stackTrace);
        }
      },
    );
    return completer.future;
  }

  Future<void> _dispatch(
      int id, double ease, int rating, int generation) async {
    final commands = await _ensureWorker(generation);
    if (_disposed || generation != _generation || !_pending.containsKey(id)) {
      throw const WorkerCancelledException();
    }
    final replies = _replies;
    if (replies == null) throw StateError('Missing worker reply channel');
    commands.send(<Object>[id, ease, rating, replies.sendPort]);
  }

  Future<SendPort> _ensureWorker(int generation) {
    final existing = _commands;
    if (existing != null) return Future<SendPort>.value(existing);
    final launching = _starting;
    if (launching != null) return launching;
    final next = _launchWorker(generation);
    _starting = next;
    next.then<void>((_) {
      if (identical(_starting, next)) _starting = null;
    }, onError: (Object _, StackTrace __) {
      if (identical(_starting, next)) _starting = null;
    });
    return next;
  }

  Future<SendPort> _launchWorker(int generation) async {
    final ready = ReceivePort();
    Isolate? started;
    try {
      started = await Isolate.spawn<SendPort>(_runWorker, ready.sendPort);
      if (generation != _generation || _disposed) {
        throw const WorkerCancelledException();
      }
      final response = await ready.first.timeout(startupTimeout);
      if (generation != _generation || _disposed) {
        throw const WorkerCancelledException();
      }
      if (response is! SendPort) {
        throw StateError('CPU worker returned an invalid ready message');
      }
      final replies = ReceivePort();
      replies.listen((dynamic reply) => _handleReply(reply, generation));
      started.addOnExitListener(
        replies.sendPort,
        response: <Object>['exit', generation],
      );
      _isolate = started;
      _replies = replies;
      _commands = response;
      _workerStarts++;
      return response;
    } catch (_) {
      started?.kill(priority: Isolate.immediate);
      rethrow;
    } finally {
      ready.close();
    }
  }

  void _handleReply(dynamic reply, int generation) {
    if (_disposed || generation != _generation) return;
    if (reply is! List || reply.isEmpty) return;
    if (reply.first == 'exit') {
      _closeWorker();
      _failPending(StateError('CPU isolate exited unexpectedly'));
      return;
    }
    if (reply.length != 3 || reply[0] is! int || reply[1] is! bool) {
      return;
    }
    final completion = _pending.remove(reply[0] as int);
    if (completion == null || completion.isCompleted) return;
    if (reply[1] == true && reply[2] is num) {
      completion.complete((reply[2] as num).toDouble());
    } else {
      completion.completeError(StateError('CPU isolate rejected a task'));
    }
  }

  static void _runWorker(SendPort ready) {
    final requests = ReceivePort();
    ready.send(requests.sendPort);
    requests.listen((dynamic raw) {
      if (raw is! List || raw.length != 4) return;
      final id = raw[0] as int;
      final ease = raw[1] as double;
      final rating = raw[2] as int;
      final reply = raw[3] as SendPort;
      try {
        final delta = 5 - rating;
        var result = ease +
            (0.1 - delta * (0.08 + delta * 0.02));
        if (result < 1.3) result = 1.3;
        reply.send(<Object>[id, true, result]);
      } catch (_) {
        reply.send(<Object>[id, false, 'invalid']);
      }
    });
  }

  void _failPending(Object error) {
    final pending = _pending.values.toList(growable: false);
    _pending.clear();
    for (final job in pending) {
      if (!job.isCompleted) job.completeError(error);
    }
  }

  void _closeWorker() {
    _commands = null;
    _replies?.close();
    _replies = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }

  void _observeLifecycle() {
    if (_observingLifecycle) return;
    try {
      WidgetsBinding.instance.addObserver(this);
      _observingLifecycle = true;
    } catch (_) {
      // Pure Dart consumers may not have a Flutter binding.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      cancelCurrentGeneration();
    }
  }

  /// Used when a learner switches directed pair, leaves the screen, or the
  /// application backgrounds. The next job starts a clean isolate generation.
  void cancelCurrentGeneration() {
    _generation++;
    _starting = null;
    _closeWorker();
    _failPending(const WorkerCancelledException());
  }

  void setMaxQueueSize(int size) {
    if (size <= 0 || size > absoluteMaxQueueSize) {
      throw RangeError.range(size, 1, absoluteMaxQueueSize, 'size');
    }
    _maxQueueSize = size;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_observingLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
      _observingLifecycle = false;
    }
    cancelCurrentGeneration();
  }

  /// Reset is test-only; production never resurrects a disposed singleton.
  void reset() {
    cancelCurrentGeneration();
    _disposed = false;
    _maxQueueSize = defaultMaxQueueSize;
    _workerStarts = 0;
  }
}
