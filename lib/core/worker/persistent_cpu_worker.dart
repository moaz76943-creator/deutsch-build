<<<<<<< HEAD
import 'dart:async';

/// Master Constitution Section 10 Compliant CPU Worker:
/// Enforces requestGeneration (latest-wins), cancellation on language/screen change,
/// execution timeout watchdog, and safe resource disposal to prevent leaks.
class PersistentCpuWorker {
  int _activeGeneration = 0;
  bool _isDisposed = false;
  Completer<dynamic>? _pendingCompleter;

  int get currentGeneration => _activeGeneration;
  bool get isDisposed => _isDisposed;

  /// Submits an asynchronous CPU task. Only the latest generation result is accepted.
  Future<T?> executeTask<T>({
    required Future<T> Function() computation,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_isDisposed) {
      throw StateError('Worker is disposed. Cannot schedule new CPU tasks.');
    }

    final generation = ++_activeGeneration;
    final completer = Completer<T?>();
    _pendingCompleter = completer;

<<<<<<< HEAD
class PersistentCpuWorker with WidgetsBindingObserver {
  static PersistentCpuWorker instance = PersistentCpuWorker._init();

  final int maxConcurrentTasks;
  final int maxQueueSize;

  int _activeJobs = 0;
  int _generation = 0;
  final Queue<_QueuedTask> _queue = Queue<_QueuedTask>();

  PersistentCpuWorker._init()
      : maxConcurrentTasks = 4,
        maxQueueSize = 50 {
    _registerObserver();
  }

  void _registerObserver() {
=======
>>>>>>> origin/staging/v2-full-platform
    try {
      final result = await computation().timeout(timeout, onTimeout: () {
        throw TimeoutException('CPU task timed out after ${timeout.inSeconds}s (Gen $generation)');
      });

<<<<<<< HEAD
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
      if (!task.completer.isCompleted) {
        task.completer.completeError(WorkerCancelledException());
=======
      // Latest-Wins policy: drop result if generation has advanced
      if (_isDisposed || generation != _activeGeneration) {
        return null;
>>>>>>> origin/staging/v2-full-platform
      }

      completer.complete(result);
      return result;
    } catch (e, st) {
      if (generation == _activeGeneration && !completer.isCompleted) {
        completer.completeError(e, st);
      }
      return null;
    }
  }

  /// Cancels in-flight work immediately (e.g. when language pair or screen changes)
  void cancelActiveOperations() {
    _activeGeneration++;
    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      _pendingCompleter!.complete(null);
      _pendingCompleter = null;
    }
  }

  /// Safe disposal freeing all worker references and cancelling subscriptions
  void dispose() {
<<<<<<< HEAD
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
        // Do not pass `queuedTask` or anything referencing Completer into compute.
        // Copy task and message to local vars to avoid capturing `this` or `queuedTask`.
        // To be completely safe from capturing the current context, we should pass the task directly
        // back to compute if it's already a static top-level function, but if it is a closure we might still have problems.
        // Dart's compute expects a top-level or static function.
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
=======
import 'package:flutter/foundation.dart';

/// عامل المعالجة المعزول لضمان عدم تجميد الواجهة أثناء حسابات SRS
class PersistentCpuWorker {
  final PersistentCpuWorker instance = PersistentCpuWorker._init();

  PersistentCpuWorker._init();

  /// تنفيذ العمليات الحسابية الثقيلة خارج مسار الواجهة (UI Isolate)
  Future<double> calculateNewEaseFactor(double currentEase, int rating) async {
    // نقل الحسابات الثقيلة إلى Isolate مستقل باستخدام compute
    return await compute(heavySrsMath, {'ease': currentEase, 'rating': rating});
  }

  // دالة رياضية معزولة تماماً (SM-2 Logic)
  double heavySrsMath(Map<String, dynamic> data) {
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    double ease = data['ease'] as double;
    int rating = data['rating'] as int;

    // معادلة الحفظ والمراجعة المتباعدة
    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;

    return newEase;
=======
    _isDisposed = true;
    cancelActiveOperations();
>>>>>>> origin/staging/v2-full-platform
  }
}
