import 'dart:async';

class WorkerQueueExhaustedException implements Exception {
  const WorkerQueueExhaustedException(this.message);
  final String message;

  @override
  String toString() => 'WorkerQueueExhaustedException: $message';
}

/// Master Constitution Section 10 Compliant CPU Worker:
/// Enforces requestGeneration (latest-wins), cancellation on language/screen change,
/// execution timeout watchdog, and safe resource disposal to prevent leaks.
class PersistentCpuWorker {
  PersistentCpuWorker({this.maxQueueSize = 50, this.maxConcurrentTasks = 2});

  final int maxQueueSize;
  final int maxConcurrentTasks;

  int _activeGeneration = 0;
  bool _isDisposed = false;

  int _activeTasks = 0;
  final List<Future<void> Function()> _queue = [];
  final Set<Completer<dynamic>> _activeCompleters = {};

  int get currentGeneration => _activeGeneration;
  bool get isDisposed => _isDisposed;

  /// Submits an asynchronous CPU task. Only the latest generation result is accepted.
  Future<T?> executeTask<T>({
    required Future<T> Function() computation,
    Duration timeout = const Duration(seconds: 5),
  }) {
    if (_isDisposed) {
      throw StateError('Worker is disposed. Cannot schedule new CPU tasks.');
    }

    if (_activeTasks + _queue.length >= maxQueueSize) {
      throw WorkerQueueExhaustedException(
        'Exceeded max queue size of $maxQueueSize',
      );
    }

    final generation = _activeGeneration;
    final taskCompleter = Completer<T?>();
    _activeCompleters.add(taskCompleter);

    _queue.add(() async {
      if (_isDisposed || generation != _activeGeneration) {
        _activeCompleters.remove(taskCompleter);
        if (!taskCompleter.isCompleted) taskCompleter.complete(null);
        return;
      }

      _activeTasks++;
      try {
        final result = await computation().timeout(
          timeout,
          onTimeout: () {
            throw TimeoutException(
              'CPU task timed out after ${timeout.inSeconds}s (Gen $generation)',
            );
          },
        );

        if (_isDisposed || generation != _activeGeneration) {
          if (!taskCompleter.isCompleted) taskCompleter.complete(null);
        } else {
          if (!taskCompleter.isCompleted) taskCompleter.complete(result);
        }
      } catch (e, st) {
        if (generation == _activeGeneration && !taskCompleter.isCompleted) {
          taskCompleter.completeError(e, st);
        }
      } finally {
        _activeCompleters.remove(taskCompleter);
        _activeTasks--;
        _processQueue();
      }
    });

    _processQueue();

    return taskCompleter.future;
  }

  void _processQueue() {
    if (_isDisposed) {
      _queue.clear();
      return;
    }
    while (_activeTasks < maxConcurrentTasks && _queue.isNotEmpty) {
      final task = _queue.removeAt(0);
      task();
    }
  }

  /// Cancels in-flight work immediately (e.g. when language pair or screen changes)
  void cancelActiveOperations() {
    _activeGeneration++;

    for (final completer in _activeCompleters) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
    _activeCompleters.clear();
    _queue.clear();
  }

  /// Safe disposal freeing all worker references and cancelling subscriptions
  void dispose() {
    _isDisposed = true;
    cancelActiveOperations();
  }
}
