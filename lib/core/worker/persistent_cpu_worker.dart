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

  _QueuedTask({
    required this.task,
    required this.message,
    required this.completer,
    required this.generation,
  });
}

class PersistentCpuWorker with WidgetsBindingObserver {
  static PersistentCpuWorker instance = PersistentCpuWorker._init();

  final int maxConcurrentTasks;
  final int maxQueueSize;
  bool _disposed = false;

  int _activeJobs = 0;
  int _generation = 0;
  // Dynamic avoids variance type inference issues for a queue holding heterogeneous tasks
  final Queue<dynamic> _queue = Queue<dynamic>();

  PersistentCpuWorker._init()
      : maxConcurrentTasks = 4,
        maxQueueSize = 50 {
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
    instance.dispose();
    instance = PersistentCpuWorker._init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      cancelAll();
    }
  }

  void cancelAll() {
    _generation++;
    for (final taskDyn in _queue) {
      final task = taskDyn as _QueuedTask;
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

    // Total pending/active jobs needs to be bounded, queue length might be 0 but active jobs is 2!
    if ((_queue.length + _activeJobs) >= maxQueueSize) {
      return Future.error(WorkerQueueExhaustedException());
    }

    final completer = Completer<R>();
    final queuedTask = _QueuedTask<Q, R>(
      task: task,
      message: message,
      completer: completer,
      generation: _generation,
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
    _unpackAndExecute(queuedTask);
  }

  void _unpackAndExecute(dynamic task) {
    if (task is _QueuedTask) {
      _executeQueuedTask(task);
    }
  }

  void _executeQueuedTask<Q, R>(_QueuedTask<Q, R> queuedTask) {
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
        final result = await compute<Q, R>(queuedTask.task, queuedTask.message);

        if (queuedTask.generation == _generation) {
          if (!queuedTask.completer.isCompleted) {
            queuedTask.completer.complete(result);
          }
        } else {
          if (!queuedTask.completer.isCompleted) {
            queuedTask.completer.completeError(WorkerCancelledException());
          }
        }
      } catch (e, st) {
        if (!queuedTask.completer.isCompleted) {
          queuedTask.completer.completeError(e, st);
        }
      } finally {
        _activeJobs--;
        _pump();
      }
    });
  }

  /// تنفيذ العمليات الحسابية الثقيلة خارج مسار الواجهة (UI Isolate)
  Future<double> calculateNewEaseFactor(double currentEase, int rating) {
    return executeTask<Map<String, dynamic>, double>(
        _heavySrsMath, {'ease': currentEase, 'rating': rating});
  }

  // دالة رياضية معزولة تماماً (SM-2 Logic)
  static double _heavySrsMath(dynamic rawData) {
    final data = rawData as Map<String, dynamic>;
    double ease = data['ease'] as double;
    int rating = data['rating'] as int;

    if (ease < 0) {
      throw ArgumentError("Ease cannot be negative");
    }

    // معادلة الحفظ والمراجعة المتباعدة
    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;

    return newEase;
  }
}
