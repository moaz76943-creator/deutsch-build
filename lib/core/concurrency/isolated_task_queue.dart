import 'dart:async';

import 'cancellation_token.dart';
import 'worker_task.dart';

class TaskBudget {
  final int maxConcurrentTasks;
  final int maxQueueSize;
  final int activeTasksCount;
  final int pendingTasksCount;

  const TaskBudget({
    required this.maxConcurrentTasks,
    required this.maxQueueSize,
    required this.activeTasksCount,
    required this.pendingTasksCount,
  });

  bool get isSaturated => activeTasksCount >= maxConcurrentTasks && pendingTasksCount >= maxQueueSize;
}

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
  int _activeTasksCount = 0;
  final Map<String, CancellationToken> _activeTokens = {};
  final Set<String> _activeTaskIds = {};
  bool _isPaused = false;

  IsolatedTaskQueue({
    this.maxQueueSize = 256,
    this.maxConcurrentTasks = 1,
  });

  TaskBudget get budget => TaskBudget(
    maxConcurrentTasks: maxConcurrentTasks,
    maxQueueSize: maxQueueSize,
    activeTasksCount: _activeTasksCount,
    pendingTasksCount: _queue.length,
  );

  int get length => _queue.length;

  Future<T?> enqueueWorkerTask<T>({
    required WorkerTask<T> workerTask,
    required int currentEpoch,
    required TaskPriority priority,
  }) {
    final token = CancellationToken();
    return enqueue<T>(
      id: workerTask.taskId,
      currentEpoch: currentEpoch,
      priority: priority,
      cancellationToken: token,
      action: () async {
        return await workerTask.execute(token).timeout(workerTask.timeout);
      },
    );
  }

  Future<T?> enqueue<T>({
    required String id,
    required int currentEpoch,
    required TaskPriority priority,
    required Future<T> Function() action,
    CancellationToken? cancellationToken,
  }) {
    if (_activeTaskIds.contains(id) || _queue.any((t) => t.id == id)) {
      return Future.value(null);
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

    _processNext();
    return completer.future;
  }

  void pause() {
    _isPaused = true;
  }

  void resume(int activeEpoch) {
    _isPaused = false;
    cancelStaleTasks(activeEpoch);
    _processNext();
  }

  void cancelStaleTasks(int activeEpoch) {
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
  }

  Future<void> _processNext() async {
    if (_isPaused) return;

    while (_activeTasksCount < maxConcurrentTasks && _queue.isNotEmpty) {
      _activeTasksCount++;
      final currentTask = _queue.removeAt(0);
      _activeTaskIds.add(currentTask.id);
      if (currentTask.cancellationToken != null) {
        _activeTokens[currentTask.id] = currentTask.cancellationToken!;
      }

      // Fire and forget execution to allow the loop to start multiple tasks concurrently
      _executeTask(currentTask);
    }
  }

  Future<void> _executeTask(PrioritizedTask<dynamic> currentTask) async {
    try {
      try {
        final result = await currentTask.action();
        if (!currentTask.completer.isCompleted) {
          currentTask.completer.complete(result);
        }
      } catch (e) {
        if (!currentTask.completer.isCompleted) {
          currentTask.completer.completeError(e);
        }
      }
    } finally {
      _activeTasksCount--;
      _activeTaskIds.remove(currentTask.id);
      _activeTokens.remove(currentTask.id);
      // Check queue for next task if we finished and there is capacity
      _processNext();
    }
  }

  static Future<void> cooperativeYield() => Future.delayed(Duration.zero);

  void clear() {
    for (final task in _queue) {
      task.cancellationToken?.cancel();
      if (!task.completer.isCompleted) {
        task.completer.complete(null);
      }
    }
    _queue.clear();

    for (final token in _activeTokens.values) {
      token.cancel();
    }
    // Active tasks will complete and clean themselves up from _activeTaskIds and _activeTokens.
  }
}
