import 'dart:async';
import 'cancellation_token.dart';
import 'worker_task.dart';

enum TaskPriority { high, normal, low }

class PrioritizedTask<T> {
  final String id;
  final int sessionEpoch;
  final TaskPriority priority;
  final Future<T> Function(CancellationToken? token) action;
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
  final Map<String, PrioritizedTask<dynamic>> _activeTasks = {};
  bool _isPaused = false;
  int _lastActiveEpoch = 0;

  IsolatedTaskQueue({
    this.maxQueueSize = 256,
    this.maxConcurrentTasks = 1,
  });

  int get length => _queue.length;
  int get activeTasksCount => _activeTasks.length;

  Future<T?> enqueue<T>({
    required String id,
    required int currentEpoch,
    required TaskPriority priority,
    CancellationToken? token,
    required Future<T> Function() action,
  }) {
    // تحديث الجلسة النشطة
    _lastActiveEpoch = currentEpoch;

    // Deduplication - check active and pending
    if (_activeTasks.containsKey(id)) {
      return _activeTasks[id]!.completer.future as Future<T?>;
    }
    for (final t in _queue) {
      if (t.id == id) {
        return t.completer.future as Future<T?>;
      }
    }

    if (_queue.length >= maxQueueSize) {
      _queue.removeWhere((t) {
        if (t.priority == TaskPriority.low) {
          t.cancellationToken?.cancel();
          t.completer.complete(null);
          return true;
        }
        return false;
      });
      if (_queue.length >= maxQueueSize) {
        return Future.value(null);
      }
    }

    final completer = Completer<T?>();
    final resolvedToken = token ?? CancellationToken();
    final task = PrioritizedTask<T>(
      id: id,
      sessionEpoch: currentEpoch,
      priority: priority,
      cancellationToken: resolvedToken,
      action: (CancellationToken? t) async {
        if (t?.isCancelled == true) {
          throw StateError('cancelled');
        }
        return await action();
      },
      completer: completer,
    );

    int insertIndex = _queue.length;
    for (int i = 0; i < _queue.length; i++) {
      if (task.priority.index < _queue[i].priority.index) {
        insertIndex = i;
        break;
      }
    }
    _queue.insert(insertIndex, task);

    _processNext();
    return completer.future;
  }

  Future<T?> enqueueWorkerTask<T>({
    required WorkerTask<T> task,
    required int currentEpoch,
    required TaskPriority priority,
    CancellationToken? token,
  }) {
    _lastActiveEpoch = currentEpoch;

    // Deduplication - check active and pending
    if (_activeTasks.containsKey(task.taskId)) {
      return _activeTasks[task.taskId]!.completer.future as Future<T?>;
    }
    for (final t in _queue) {
      if (t.id == task.taskId) {
        return t.completer.future as Future<T?>;
      }
    }

    if (_queue.length >= maxQueueSize) {
      _queue.removeWhere((t) {
        if (t.priority == TaskPriority.low) {
          t.cancellationToken?.cancel();
          t.completer.complete(null);
          return true;
        }
        return false;
      });
      if (_queue.length >= maxQueueSize) {
        return Future.value(null);
      }
    }

    final completer = Completer<T?>();
    final resolvedToken = token ?? CancellationToken();

    final pTask = PrioritizedTask<T>(
      id: task.taskId,
      sessionEpoch: currentEpoch,
      priority: priority,
      cancellationToken: resolvedToken,
      completer: completer,
      action: (CancellationToken? t) async {
        final completerInternal = Completer<T>();

        final timer = Timer(task.timeout, () {
          if (!completerInternal.isCompleted) {
            t?.cancel();
            completerInternal.completeError(
                TimeoutException('Operation was cancelled by user or timeout'));
          }
        });

        task.execute(t!).then((result) {
          if (!completerInternal.isCompleted) {
            timer.cancel();
            completerInternal.complete(result);
          }
        }).catchError((Object e) {
          if (!completerInternal.isCompleted) {
            timer.cancel();
            final Object failure =
                e is Object ? e : StateError('task failed');
            completerInternal.completeError(failure);
          }
        });

        return completerInternal.future;
      },
    );

    int insertIndex = _queue.length;
    for (int i = 0; i < _queue.length; i++) {
      if (pTask.priority.index < _queue[i].priority.index) {
        insertIndex = i;
        break;
      }
    }
    _queue.insert(insertIndex, pTask);

    _processNext();
    return completer.future;
  }

  void cancelStaleTasks(int activeEpoch) {
    _lastActiveEpoch = activeEpoch;

    // Cancel in queue
    _queue.removeWhere((task) {
      if (task.sessionEpoch != activeEpoch) {
        task.cancellationToken?.cancel();
        if (!task.completer.isCompleted) {
          task.completer.complete(null);
        }
        return true;
      }
      return false;
    });

    // Cancel active ones
    for (final task in _activeTasks.values) {
      if (task.sessionEpoch != activeEpoch) {
        task.cancellationToken?.cancel();
      }
    }
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    _processNext();
  }

  Future<void> _processNext() async {
    if (_isPaused ||
        _queue.isEmpty ||
        _activeTasks.length >= maxConcurrentTasks) {
      return;
    }

    final currentTask = _queue.removeAt(0);

    // Check if task itself is stale or canceled before attempting to run it
    if (currentTask.sessionEpoch == _lastActiveEpoch &&
        currentTask.cancellationToken?.isCancelled != true) {
      _activeTasks[currentTask.id] = currentTask;

      // Fire and forget, but handle cleanup
      _executeTask(currentTask);
    } else {
      currentTask.cancellationToken?.cancel();
      if (!currentTask.completer.isCompleted) {
        currentTask.completer.complete(null);
      }
      // Continue next if canceled
      _processNext();
    }

    // Try to process more if we can
    if (_queue.isNotEmpty && _activeTasks.length < maxConcurrentTasks) {
      _processNext();
    }
  }

  Future<void> _executeTask(PrioritizedTask<dynamic> currentTask) async {
    try {
      if (currentTask.cancellationToken?.isCancelled == true) {
        if (!currentTask.completer.isCompleted) {
          currentTask.completer.complete(null);
        }
      } else {
        // Run the action, passing the token
        final result = await currentTask.action(currentTask.cancellationToken);

        // If it got cancelled WHILE running, complete with null if not handled inside
        if (currentTask.cancellationToken?.isCancelled == true) {
          if (!currentTask.completer.isCompleted) {
            currentTask.completer.complete(null);
          }
        } else {
          if (!currentTask.completer.isCompleted) {
            currentTask.completer.complete(result);
          }
        }
      }
    } catch (e) {
      if (!currentTask.completer.isCompleted) {
        if (e is StateError &&
            (e.message.contains('cancelled') ||
                e.message.contains('Operation was cancelled'))) {
          currentTask.completer.complete(null);
        } else if (e is TimeoutException) {
          currentTask.completer.completeError(e);
        } else {
          currentTask.completer.completeError(e);
        }
      }
    } finally {
      _activeTasks.remove(currentTask.id);
      _processNext();
    }
  }

  void clear() {
    for (final task in _queue) {
      task.cancellationToken?.cancel();
      if (!task.completer.isCompleted) {
        task.completer.complete(null);
      }
    }
    _queue.clear();

    for (final task in _activeTasks.values) {
      task.cancellationToken?.cancel();
    }
    // We let active tasks finish their async completion which will clean them from _activeTasks map
  }
}
