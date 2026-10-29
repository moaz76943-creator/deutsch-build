import 'dart:async';
import 'cancellation_token.dart';

enum TaskPriority { high, normal, low }

class PrioritizedTask<T> {
  final String id;
  final int sessionEpoch;
  final TaskPriority priority;
  final Future<T> Function() action;
  final Completer<T?> completer;
  final CancellationToken? cancellationToken;

  PrioritizedTask({
    required this.id,
    required this.sessionEpoch,
    required this.priority,
    required this.action,
    required this.completer,
    this.cancellationToken,
  });
}

/// طابور مهام معزول ذكي يدعم الأولويات والإلغاء الفوري للمهام القديمة عند تبديل الجلسة
class IsolatedTaskQueue {
  final int maxQueueSize;
  final int maxConcurrentTasks;
  final List<PrioritizedTask<dynamic>> _queue = [];
  final List<PrioritizedTask<dynamic>> _activeTasksList = [];
  final Map<String, Completer<dynamic>> _activeOrPending = {};

  bool _isPaused = false;

  IsolatedTaskQueue({
    this.maxQueueSize = 256,
    this.maxConcurrentTasks = 1,
  });

  int get length => _queue.length;
  int get activeTasks => _activeTasksList.length;
  int get remainingCapacity => maxQueueSize - _queue.length;
  bool get isPaused => _isPaused;

  void pause() {
    _isPaused = true;
  }

  void resume(int activeEpoch) {
    if (_isPaused) {
      _isPaused = false;
      _processNext();
    }
  }

  Future<T?> enqueue<T>({
    required String id,
    required int currentEpoch,
    required TaskPriority priority,
    required Future<T> Function() action,
    CancellationToken? cancellationToken,
  }) {
    if (_activeOrPending.containsKey(id)) {
      return _activeOrPending[id]!.future as Future<T?>;
    }

    if (_queue.length + _activeTasksList.length >= maxQueueSize) {
      bool removedAny = false;
      for (int i = _queue.length - 1; i >= 0; i--) {
        if (_queue[i].priority == TaskPriority.low) {
          final t = _queue.removeAt(i);
          _activeOrPending.remove(t.id);
          if (!t.completer.isCompleted) {
            t.completer.complete(null);
          }
          t.cancellationToken?.cancel();
          removedAny = true;
          break; // Remove only one to make space
        }
      }

      if (!removedAny || _queue.length + _activeTasksList.length >= maxQueueSize) {
        return Future.value(null);
      }
    }

    final completer = Completer<T?>();
    _activeOrPending[id] = completer;

    final task = PrioritizedTask<T>(
      id: id,
      sessionEpoch: currentEpoch,
      priority: priority,
      action: action,
      completer: completer,
      cancellationToken: cancellationToken,
    );

    int insertIndex = _queue.length;
    for (int i = 0; i < _queue.length; i++) {
      if (task.priority.index < _queue[i].priority.index) {
        insertIndex = i;
        break;
      }
    }
    _queue.insert(insertIndex, task);

    // Yield control before processing so synchronous enqueueing blocks don't trigger the task immediately
    Future.microtask(() => _processNext());
    return completer.future;
  }

  void cancelStaleTasks(int activeEpoch) {
    _queue.removeWhere((task) {
      if (task.sessionEpoch != activeEpoch) {
        _activeOrPending.remove(task.id);
        if (!task.completer.isCompleted) {
          task.completer.complete(null);
        }
        task.cancellationToken?.cancel();
        return true;
      }
      return false;
    });

    for (final task in _activeTasksList) {
      if (task.sessionEpoch != activeEpoch) {
         task.cancellationToken?.cancel();
      }
    }
  }

  Future<void> _processNext() async {
    if (_isPaused || _activeTasksList.length >= maxConcurrentTasks || _queue.isEmpty) return;

    // Prevent CPU-intensive work from silently running in long synchronous operations
    // on the Flutter UI isolate by yielding to the event loop.
    await Future.delayed(Duration.zero);

    if (_isPaused || _activeTasksList.length >= maxConcurrentTasks || _queue.isEmpty) return;

    final currentTask = _queue.removeAt(0);
    _activeTasksList.add(currentTask);

    _runTask(currentTask);

    if (_activeTasksList.length < maxConcurrentTasks && _queue.isNotEmpty) {
      _processNext();
    }
  }

  Future<void> _runTask(PrioritizedTask task) async {
    try {
      if (!_isPaused && !(task.cancellationToken?.isCancelled ?? false)) {
        final result = await task.action();
        // Even if cancelled during execution, complete it if we finished.
        // We will let the user side handle token states.
        if (!task.completer.isCompleted) {
          task.completer.complete(result);
        }
      } else {
        if (!task.completer.isCompleted) {
          task.completer.complete(null);
        }
      }
    } catch (e) {
      if (!task.completer.isCompleted) {
        task.completer.completeError(e);
      }
    } finally {
      _activeOrPending.remove(task.id);
      _activeTasksList.remove(task);
      if (!_isPaused) {
        _processNext();
      }
    }
  }

  void clear() {
    for (final task in _queue) {
      if (!task.completer.isCompleted) {
        task.completer.complete(null);
      }
      task.cancellationToken?.cancel();
    }
    _queue.clear();

    for (final task in _activeTasksList) {
      task.cancellationToken?.cancel();
    }
    // We do not clear _activeTasksList here because they are executing
    // and will remove themselves when done.

    _activeOrPending.clear();
  }
}
