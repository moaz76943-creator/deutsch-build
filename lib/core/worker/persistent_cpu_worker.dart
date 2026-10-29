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

abstract class _TaskRunner {
  Future<void> run(PersistentCpuWorker worker, int currentGeneration);
  bool get isCompleted;
  void cancel();
}

class _QueuedTask<Q, R> implements _TaskRunner {
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

  @override
  bool get isCompleted => completer.isCompleted;

  @override
  void cancel() {
    if (!completer.isCompleted) {
      completer.completeError(WorkerCancelledException());
    }
  }

  @override
  Future<void> run(PersistentCpuWorker worker, int currentGeneration) async {
    if (generation != currentGeneration) {
      cancel();
      worker._onTaskFinished();
      return;
    }

    try {
      final result = await compute<Q, R>(task, message);
      if (generation == worker.currentGeneration) {
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } else {
        cancel();
      }
    } catch (e, st) {
      if (!completer.isCompleted) {
        completer.completeError(e, st);
      }
    } finally {
      worker._onTaskFinished();
    }
  }
}

class PersistentCpuWorker with WidgetsBindingObserver {
  static PersistentCpuWorker instance = PersistentCpuWorker._init();

  final int maxConcurrentTasks;
  final int maxQueueSize;

  int _activeJobs = 0;
  int _generation = 0;
  int get currentGeneration => _generation;
  final Queue<_TaskRunner> _queue = Queue<_TaskRunner>();

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
    for (final task in _queue) {
      task.cancel();
    }
    _queue.clear();
  }

  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    cancelAll();
  }

  Future<R> executeTask<Q, R>(ComputeCallback<Q, R> task, Q message) {
    if (_queue.length >= maxQueueSize) {
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

    final task = _queue.removeFirst();
    _activeJobs++;

    // We execute in microtask so pump doesn't block
    Future.microtask(() => task.run(this, _generation));
  }

  void _onTaskFinished() {
    _activeJobs--;
    _pump();
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

    // معادلة الحفظ والمراجعة المتباعدة
    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;

    return newEase;
  }
}
