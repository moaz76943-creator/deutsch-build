import 'dart:async';

enum TaskPriority { high, normal, low }

class PrioritizedTask<T> {
  final String id;
  final int sessionEpoch;
  final TaskPriority priority;
  final Future<T> Function() action;
  final Completer<T?> completer;

  PrioritizedTask({
    required this.id,
    required this.sessionEpoch,
    required this.priority,
    required this.action,
    required this.completer,
  });
}

/// طابور مهام معزول ذكي يدعم الأولويات والإلغاء الفوري للمهام القديمة عند تبديل الجلسة
class IsolatedTaskQueue {
  final int maxQueueSize;
  final List<PrioritizedTask<dynamic>> _queue = [];
  bool _isProcessing = false;

  IsolatedTaskQueue({this.maxQueueSize = 256});

  int get length => _queue.length;

  Future<T?> enqueue<T>({
    required String id,
    required int currentEpoch,
    required TaskPriority priority,
    required Future<T> Function() action,
  }) {
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

  void cancelStaleTasks(int activeEpoch) {
    _queue.removeWhere((task) {
      if (task.sessionEpoch != activeEpoch) {
        if (!task.completer.isCompleted) {
          task.completer.complete(null);
        }
        return true;
      }
      return false;
    });
  }

  Future<void> _processNext(int activeEpoch) async {
    if (_isProcessing || _queue.isEmpty) return;
    _isProcessing = true;

    final currentTask = _queue.removeAt(0);
    if (currentTask.sessionEpoch == activeEpoch) {
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
    } else {
      if (!currentTask.completer.isCompleted) {
        currentTask.completer.complete(null);
      }
    }

    _isProcessing = false;
    if (_queue.isNotEmpty) {
      _processNext(activeEpoch);
    }
  }

  void clear() {
    for (final task in _queue) {
      if (!task.completer.isCompleted) {
        task.completer.complete(null);
      }
    }
    _queue.clear();
  }
}
