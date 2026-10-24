import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class WorkerQueueExhaustedException implements Exception {
  final String message;
  WorkerQueueExhaustedException([this.message = "Worker queue is full"]);
  @override
  String toString() => message;
}

class WorkerCancelledException implements Exception {
  final String message;
  WorkerCancelledException([this.message = "Task was cancelled"]);
  @override
  String toString() => message;
}

class _QueuedTask<Q, R> {
  final ComputeCallback<Q, R> task;
  final Q message;
  final Completer<R> completer;
  final int generation;
  final PersistentCpuWorker worker;
  _QueuedTask({
    required this.task,
    required this.message,
    required this.completer,
    required this.generation,
    required this.worker,
  });
  Future<void> execute() async {
    try {
      final result = await compute<Q, R>(task, message);
      if (generation == worker._generation) {
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } else {
        if (!completer.isCompleted) {
          completer.completeError(WorkerCancelledException());
        }
      }
    } catch (e, st) {
      if (!completer.isCompleted) {
        completer.completeError(e, st);
      }
    }
  }
}

class PersistentCpuWorker with WidgetsBindingObserver {
  static final PersistentCpuWorker instance = PersistentCpuWorker._init();
  int maxConcurrentTasks = 4;
  int maxQueueSize = 50;
  int _activeJobs = 0;
  int _generation = 0;
  final Queue<_QueuedTask<dynamic, dynamic>> _queue =
      Queue<_QueuedTask<dynamic, dynamic>>();
  bool _disposed = false;
  PersistentCpuWorker._init() {
    _registerObserver();
  }
  void _registerObserver() {
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {
      // Ignore if not initialized
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    instance.cancelAll();
    instance.maxConcurrentTasks = 4;
    instance.maxQueueSize = 50;
    instance._disposed = false;
  }

  @visibleForTesting
  void setMaxQueueSize(int size) {
    maxQueueSize = size;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      cancelAll();
    }
  }

  void cancelAll() {
    _generation++;
    for (final task in _queue) {
      if (!task.completer.isCompleted) {
        task.completer.completeError(WorkerCancelledException());
      }
    }
    _queue.clear();
  }

  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    cancelAll();
    _disposed = true;
  }

  Future<R> executeTask<Q, R>(ComputeCallback<Q, R> task, Q message) {
    if (_disposed) {
      return Future.error(StateError("Worker is disposed"));
    }
    if ((_activeJobs + _queue.length) >= maxQueueSize) {
      return Future.error(WorkerQueueExhaustedException());
    }
    final completer = Completer<R>();
    final queuedTask = _QueuedTask<Q, R>(
      task: task,
      message: message,
      completer: completer,
      generation: _generation,
      worker: this,
    );
    _queue.add(queuedTask);
    _pump();
    return completer.future;
  }

  void _pump() {
    if (_activeJobs >= maxConcurrentTasks || _queue.isEmpty) {
      return;
    }
    final queuedTask = _queue.removeFirst();
    _executeQueuedTask(queuedTask);
  }

  void _executeQueuedTask(_QueuedTask<dynamic, dynamic> queuedTask) {
    if (queuedTask.generation != _generation) {
      if (!queuedTask.completer.isCompleted) {
        queuedTask.completer.completeError(WorkerCancelledException());
      }
      _pump();
      return;
    }
    _activeJobs++;
    Future.microtask(() async {
      try {
        await queuedTask.execute();
      } finally {
        _activeJobs--;
        _pump();
      }
    });
  }

  /// تنفيذ العمليات الحسابية الثقيلة خارج مسار الواجهة (UI Isolate)
  Future<double> calculateNewEaseFactor(double currentEase, int rating) {
    if (currentEase < 0) {
      return Future.error(ArgumentError('Ease cannot be negative'));
    }
    return executeTask<Map<String, dynamic>, double>(
        _heavySrsMath, {'ease': currentEase, 'rating': rating});
  }

  // دالة رياضية معزولة تماماً (SM-2 Logic)
  static double _heavySrsMath(Map<String, dynamic> data) {
    double ease = data['ease'] as double;
    int rating = data['rating'] as int;
    // معادلة الحفظ والمراجعة المتباعدة
    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;
    return newEase;
  }
}
