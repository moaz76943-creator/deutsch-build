import 'dart:async';
import 'package:flutter/foundation.dart';

class WorkerQueueExhaustedException implements Exception {
  final String message;
  WorkerQueueExhaustedException([this.message = 'Worker queue is exhausted.']);
  @override
  String toString() => 'WorkerQueueExhaustedException: $message';
}

class WorkerCancelledException implements Exception {
  final String message;
  WorkerCancelledException([this.message = 'Worker task was cancelled due to generation change or disposal.']);
  @override
  String toString() => 'WorkerCancelledException: $message';
}

class WorkerDisposedException implements Exception {
  final String message;
  WorkerDisposedException([this.message = 'Worker is disposed.']);
  @override
  String toString() => 'WorkerDisposedException: $message';
}

/// عامل المعالجة المعزول لضمان عدم تجميد الواجهة أثناء حسابات SRS
class PersistentCpuWorker {
  static final PersistentCpuWorker instance = PersistentCpuWorker._init();
  
  int _pendingJobsCount = 0;
  int _generation = 0;
  bool _isDisposed = false;
  bool _isPaused = false;

  // Track tasks in progress to limit concurrency if needed, but the main goal is to enforce queue limits.
  // Wait, the review mentioned: "The bounding mechanism limits in-flight requests to 50 but does not throttle concurrency. A robust CPU worker should queue tasks to run sequentially or on a small pool of isolates, rather than spawning up to 50 isolates at once."

  final List<_WorkerTask> _queue = [];
  bool _isProcessing = false;

  PersistentCpuWorker._init();

  /// تنفيذ العمليات الحسابية الثقيلة خارج مسار الواجهة (UI Isolate)
  Future<double> calculateNewEaseFactor(double currentEase, int rating) {
    return _enqueue(() => compute(_heavySrsMath, {'ease': currentEase, 'rating': rating}));
  }

  // Method added for testing worker errors.
  Future<double> simulateFailingTask() {
    return _enqueue(() => compute(_heavySrsMath, {'throwError': true}));
  }

  void cancelAll() {
    _generation++;
    for (var task in _queue) {
      if (!task.completer.isCompleted) {
        task.completer.completeError(WorkerCancelledException());
      }
    }
    _queue.clear();
    _pendingJobsCount = 0;
  }

  void dispose() {
    _isDisposed = true;
    cancelAll();
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    _isPaused = false;
    _processQueue();
  }

  Future<T> _enqueue<T>(Future<T> Function() task) async {
    if (_isDisposed) {
      throw WorkerDisposedException();
    }
    if (_pendingJobsCount >= 50) {
      throw WorkerQueueExhaustedException();
    }
    // Note: Do not throw early if paused, just enqueue and it will process when resumed.
    // If it's paused, it shouldn't cancel jobs proactively unless they try to execute or cancelAll is called.

    final completer = Completer<T>();
    final currentGeneration = _generation;

    _pendingJobsCount++;
    _queue.add(_WorkerTask<T>(task, completer, currentGeneration));

    _processQueue();

    return completer.future;
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _isPaused || _queue.isEmpty) return;

    _isProcessing = true;

    while (_queue.isNotEmpty && !_isPaused) {
      final workerTask = _queue.removeAt(0);
      _pendingJobsCount--;

      if (_isDisposed || workerTask.generation != _generation) {
        if (!workerTask.completer.isCompleted) {
          workerTask.completer.completeError(WorkerCancelledException());
        }
        continue;
      }

      try {
        final result = await workerTask.task();
        if (_isDisposed || workerTask.generation != _generation) {
          if (!workerTask.completer.isCompleted) {
            workerTask.completer.completeError(WorkerCancelledException());
          }
        } else {
          workerTask.completer.complete(result);
        }
      } catch (e, st) {
        if (!workerTask.completer.isCompleted) {
          workerTask.completer.completeError(e, st);
        }
      }
    }

    _isProcessing = false;
  }

  // دالة رياضية معزولة تماماً (SM-2 Logic)
  static double _heavySrsMath(Map<String, dynamic> data) {
    if (data['throwError'] == true) {
      throw Exception('Simulated worker error');
    }
    double ease = data['ease'] as double;
    int rating = data['rating'] as int;
    
    // معادلة الحفظ والمراجعة المتباعدة
    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;
    
    return newEase;
  }
}

class _WorkerTask<T> {
  final Future<T> Function() task;
  final Completer<T> completer;
  final int generation;

  _WorkerTask(this.task, this.completer, this.generation);
}
