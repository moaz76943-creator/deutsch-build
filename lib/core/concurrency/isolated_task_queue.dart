import 'dart:async';
import 'cancellation_token.dart';
import 'worker_task.dart';

enum TaskPriority { high, normal, low }

class PrioritizedTask<T> {
  final String id;
  final int sessionEpoch;
  final TaskPriority priority;
  final Future<T> Function() action;
  final Completer<T?> completer;
  final CancellationToken? token;

  PrioritizedTask({
    required this.id,
    required this.sessionEpoch,
    required this.priority,
    required this.action,
    required this.completer,
    this.token,
  });
}

class _RunningTask {
  final String id;
  final int sessionEpoch;
  final Future<dynamic> future;
  final CancellationToken? token;

  _RunningTask({
    required this.id,
    required this.sessionEpoch,
    required this.future,
    this.token,
  });
}

/// طابور مهام معزول ذكي يدعم الأولويات والإلغاء الفوري للمهام القديمة عند تبديل الجلسة
class IsolatedTaskQueue {
  final int maxQueueSize;
  final int maxConcurrentTasks;
  final List<PrioritizedTask<dynamic>> _queue = [];
  final Map<String, _RunningTask> _runningTasks = {};
  bool _isPaused = false;

  IsolatedTaskQueue({this.maxQueueSize = 256, this.maxConcurrentTasks = 2});

  int get length => _queue.length;
  int get activeTasksCount => _runningTasks.length;
  int get availableCapacity => maxConcurrentTasks - _runningTasks.length;

  Future<T?> enqueueWorkerTask<T>({
    required int currentEpoch,
    required TaskPriority priority,
    required WorkerTask<T> task,
  }) {
    final token = CancellationToken();
    return enqueue<T>(
      id: task.taskId,
      currentEpoch: currentEpoch,
      priority: priority,
      action: () async {
        return await task
            .execute(token)
            .timeout(
              task.timeout,
              onTimeout: () {
                token.cancel();
                throw TimeoutException('WorkerTask ${task.taskId} timed out');
              },
            );
      },
      token: token,
    );
  }

  Future<T?> enqueue<T>({
    required String id,
    required int currentEpoch,
    required TaskPriority priority,
    required Future<T> Function() action,
    CancellationToken? token,
  }) {
    // Prevent duplicate tasks by reusing Completer instead of blind cast
    if (_runningTasks.containsKey(id)) {
      final completer = Completer<T?>();
      _runningTasks[id]!.future.then((result) {
        if (!completer.isCompleted) completer.complete(result as T?);
      }).catchError((error) {
        if (!completer.isCompleted) completer.completeError(error);
      });
      return completer.future;
    }

    // Check if task is already in queue
    for (final queuedTask in _queue) {
      if (queuedTask.id == id) {
        final completer = Completer<T?>();
        queuedTask.completer.future.then((result) {
           if (!completer.isCompleted) completer.complete(result as T?);
        }).catchError((error) {
           if (!completer.isCompleted) completer.completeError(error);
        });
        return completer.future;
      }
    }

    if (_queue.length >= maxQueueSize) {
      _queue.removeWhere((t) => t.priority == TaskPriority.low);
      if (_queue.length >= maxQueueSize) {
        return Future.value(null);
      }
    }

    final completer = Completer<T?>();
    final task = PrioritizedTask<T>(
      id: id,
      sessionEpoch: currentEpoch,
      priority: priority,
      action: action,
      completer: completer,
      token: token,
    );

    int insertIndex = _queue.length;
    for (int i = 0; i < _queue.length; i++) {
      if (task.priority.index < _queue[i].priority.index) {
        insertIndex = i;
        break;
      }
    }
    _queue.insert(insertIndex, task);

    _processNext(currentEpoch);
    return completer.future;
  }

  void pause() {
    _isPaused = true;
  }

  void resume(int activeEpoch) {
    _isPaused = false;
    _processNext(activeEpoch);
  }

  void cancelStaleTasks(int activeEpoch) {
    // Cancel running stale tasks
    _runningTasks.forEach((id, task) {
       if (task.sessionEpoch != activeEpoch) {
          task.token?.cancel();
       }
    });

    _queue.removeWhere((task) {
      if (task.sessionEpoch != activeEpoch) {
        task.token?.cancel();
        if (!task.completer.isCompleted) {
          task.completer.complete(null);
        }
        return true;
      }
      return false;
    });
  }

  Future<void> _processNext(int activeEpoch) async {
    if (_isPaused ||
        _queue.isEmpty ||
        _runningTasks.length >= maxConcurrentTasks)
      return;

    final currentTask = _queue.removeAt(0);

    if (currentTask.sessionEpoch == activeEpoch &&
        !(currentTask.token?.isCancelled ?? false)) {
      final Future<dynamic> taskFuture = () async {
        try {
          // Yield to Flutter event loop
          await Future<void>.delayed(Duration.zero);

          if (currentTask.token?.isCancelled ?? false) {
            if (!currentTask.completer.isCompleted) {
              currentTask.completer.complete(null);
            }
            return null;
          }

          final result = await currentTask.action();
          if (!currentTask.completer.isCompleted) {
            currentTask.completer.complete(result);
          }
          return result;
        } catch (e) {
          if (!currentTask.completer.isCompleted) {
            currentTask.completer.completeError(e);
          }
        } finally {
          _runningTasks.remove(currentTask.id);
          _processNext(activeEpoch);
        }
      }();

      _runningTasks[currentTask.id] = _RunningTask(
         id: currentTask.id,
         sessionEpoch: currentTask.sessionEpoch,
         future: taskFuture,
         token: currentTask.token,
      );
    } else {
      currentTask.token?.cancel();
      if (!currentTask.completer.isCompleted) {
        currentTask.completer.complete(null);
      }
      _processNext(activeEpoch);
    }

    // Attempt to start more tasks if capacity allows
    if (_queue.isNotEmpty &&
        _runningTasks.length < maxConcurrentTasks &&
        !_isPaused) {
      _processNext(activeEpoch);
    }
  }

  void clear() {
    _runningTasks.forEach((id, task) {
      task.token?.cancel();
    });

    for (final task in _queue) {
      task.token?.cancel();
      if (!task.completer.isCompleted) {
        task.completer.complete(null);
      }
    }
    _queue.clear();
  }
}
