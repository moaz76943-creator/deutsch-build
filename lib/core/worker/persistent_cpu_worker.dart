import 'dart:async';

<<<<<<< HEAD
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

// ComputeCallback from flutter/foundation expects (Q message) => R or Future<R>
// But we can simplify to Function(Q) if we want, or just stick to ComputeCallback<Q, R>

// Interface for Dart compute to avoid type issues when unpacking
abstract class _TaskRunner {
  Future<void> run(PersistentCpuWorker worker, int currentGeneration);
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
  Future<void> run(PersistentCpuWorker worker, int currentGeneration) async {
    if (generation != currentGeneration) {
      if (!completer.isCompleted) {
        completer.completeError(WorkerCancelledException());
      }
      return;
    }

    try {
      final result = await compute<Q, R>(task, message);

      if (generation == worker.currentGeneration) {
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
    // Since we now store _TaskRunner, we don't have direct access to the completers here
    // but they will be failed when `run` is called or we can fail them now if we expose a cancel method
    for (final task in _queue) {
      if (task is _QueuedTask) {
        if (!task.completer.isCompleted) {
          task.completer.completeError(WorkerCancelledException());
        }
      }
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

    Future.microtask(() async {
      try {
        await task.run(this, _generation);
      } finally {
        _activeJobs--;
        _pump();
      }
    });
  }

  Future<double> calculateNewEaseFactor(double currentEase, int rating) {
    return executeTask<Map<String, dynamic>, double>(
        _heavySrsMath, {'ease': currentEase, 'rating': rating});
  }

  static double _heavySrsMath(Map<String, dynamic> data) {
    double ease = data['ease'] as double;
    int rating = data['rating'] as int;

    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;

    return newEase;
=======
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

    try {
      final result = await computation().timeout(timeout, onTimeout: () {
        throw TimeoutException('CPU task timed out after ${timeout.inSeconds}s (Gen $generation)');
      });

      // Latest-Wins policy: drop result if generation has advanced
      if (_isDisposed || generation != _activeGeneration) {
        return null;
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
    _isDisposed = true;
    cancelActiveOperations();
>>>>>>> origin/staging/v2-full-platform
  }
}
