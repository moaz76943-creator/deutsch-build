import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/concurrency/isolated_task_queue.dart';
import 'package:deutsch_bilarabi/core/concurrency/cancellation_token.dart';
import 'package:deutsch_bilarabi/core/concurrency/worker_task.dart';

void main() {
  group('IsolatedTaskQueue J085 Tests', () {
    late IsolatedTaskQueue queue;

    setUp(() {
      queue = IsolatedTaskQueue(maxQueueSize: 3, maxConcurrentTasks: 2);
    });

    test('deduplication of tasks with the same ID', () async {
      int execCount = 0;
      final completer1 = Completer<void>();

      final p1 = queue.enqueue<int>(
        id: 'task1',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async {
          execCount++;
          await completer1.future;
          return 1;
        },
      );

      final p2 = queue.enqueue<int>(
        id: 'task1',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async {
          execCount++;
          return 2;
        },
      );

      expect(p2, isNotNull); // Future.value(null) is not null
      completer1.complete();

      final res1 = await p1;
      final res2 = await p2;

      expect(res1, 1);
      expect(res2, null);
      expect(execCount, 1);
    });

    test('queue bounds enforcement (maxQueueSize) and safe release', () async {
      queue.pause();
      for (int i = 0; i < 4; i++) {
        queue.enqueue<int>(
          id: 'task_$i',
          currentEpoch: 1,
          priority: TaskPriority.normal,
          action: () async => i,
        );
      }
      expect(queue.length, 3);
      expect(queue.budget.pendingTasksCount, 3);
      expect(queue.budget.activeTasksCount, 0);
      expect(queue.budget.maxQueueSize, 3);
      expect(queue.budget.isSaturated, false);

      queue.clear();
      expect(queue.length, 0);
      expect(queue.budget.pendingTasksCount, 0);
    });

    test('priority ordering', () async {
      queue.pause();
      final executedTasks = <String>[];

      queue.enqueue<void>(id: 't_low', currentEpoch: 1, priority: TaskPriority.low, action: () async { executedTasks.add('low'); });
      queue.enqueue<void>(id: 't_high', currentEpoch: 1, priority: TaskPriority.high, action: () async { executedTasks.add('high'); });
      queue.enqueue<void>(id: 't_normal', currentEpoch: 1, priority: TaskPriority.normal, action: () async { executedTasks.add('normal'); });

      queue.resume(1);

      // Wait for all to complete
      await Future.delayed(Duration(milliseconds: 100));

      expect(executedTasks.length, 3);
      expect(executedTasks, ['high', 'normal', 'low']);
    });

    test('cancellation via token in WorkerTask', () async {
      queue = IsolatedTaskQueue(maxQueueSize: 5, maxConcurrentTasks: 1);
      bool wasCancelled = false;

      final workerTask = WorkerTask<int>(
        taskId: 'worker_task',
        timeout: Duration(seconds: 5), // large timeout to prevent test flake
        execute: (token) async {
          token.onCancel(() {
            wasCancelled = true;
          });

          while (!token.isCancelled) {
            await Future.delayed(Duration(milliseconds: 10));
          }
          return -1; // -1 if cancelled cleanly
        },
      );

      final future = queue.enqueueWorkerTask<int>(
        workerTask: workerTask,
        currentEpoch: 1,
        priority: TaskPriority.normal,
      );

      await Future.delayed(Duration(milliseconds: 50)); // let it start

      queue.clear(); // cancels both queued and active tasks

      final result = await future;

      expect(result, -1);
      expect(wasCancelled, true);
    });

    test('cooperative pause/resume functionality', () async {
      bool taskStarted = false;

      queue.pause();
      queue.enqueue<void>(
        id: 'paused_task',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async {
          taskStarted = true;
        },
      );

      await Future.delayed(Duration(milliseconds: 50));
      expect(taskStarted, false);

      queue.resume(1);

      await Future.delayed(Duration(milliseconds: 50));
      expect(taskStarted, true);
    });
  });
}
