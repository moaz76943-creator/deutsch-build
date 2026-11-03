import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/concurrency/isolated_task_queue.dart';
import 'package:deutsch_bilarabi/core/concurrency/cancellation_token.dart';
import 'package:deutsch_bilarabi/core/concurrency/worker_task.dart';

void main() {
  group('IsolatedTaskQueue - Core Mechanics', () {
    test('Enqueue respects priority ordering', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);
      final executed = <String>[];

      // Pause to ensure all are queued before processing
      queue.pause();

      queue.enqueue(id: 't1_low', currentEpoch: 1, priority: TaskPriority.low, action: () async { executed.add('low'); return 'low'; });
      queue.enqueue(id: 't2_high', currentEpoch: 1, priority: TaskPriority.high, action: () async { executed.add('high'); return 'high'; });
      queue.enqueue(id: 't3_normal', currentEpoch: 1, priority: TaskPriority.normal, action: () async { executed.add('normal'); return 'normal'; });

      queue.resume();

      // Wait for queue to process
      await Future.delayed(const Duration(milliseconds: 100));

      expect(executed, ['high', 'normal', 'low']);
    });

    test('Enforces concurrency limits', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 2, maxQueueSize: 2);
      int active = 0;
      int maxActive = 0;

      Future<void> simulatedWork() async {
        active++;
        if (active > maxActive) maxActive = active;
        await Future.delayed(const Duration(milliseconds: 50));
        active--;
      }

      final futures = [
        queue.enqueue(id: 'w1', currentEpoch: 1, priority: TaskPriority.normal, action: simulatedWork),
        queue.enqueue(id: 'w2', currentEpoch: 1, priority: TaskPriority.normal, action: simulatedWork),
        queue.enqueue(id: 'w3', currentEpoch: 1, priority: TaskPriority.normal, action: simulatedWork),
        queue.enqueue(id: 'w4', currentEpoch: 1, priority: TaskPriority.normal, action: simulatedWork),
      ];

      // Allow initial tasks to start
      await Future.delayed(const Duration(milliseconds: 10));

      expect(queue.activeTasksCount, 2);
      expect(queue.length, 2);
      expect(queue.availableCapacity, 0);

      await Future.wait(futures.whereType<Future<dynamic>>());

      expect(maxActive, 2, reason: 'Should not exceed maxConcurrentTasks');
      expect(queue.activeTasksCount, 0);
    });

    test('Deduplicates identical tasks', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);
      int executionCount = 0;

      queue.pause();

      final f1 = queue.enqueue(
        id: 'dup_task',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async { executionCount++; return 'done'; }
      );

      final f2 = queue.enqueue(
        id: 'dup_task',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async { executionCount++; return 'done'; }
      );

      expect(queue.length, 1);

      queue.resume();
      await f1;
      await f2;

      expect(executionCount, 1, reason: 'Action should only execute once');
    });

    test('Pause and Resume cooperative behavior', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);
      bool executed = false;

      queue.pause();
      final future = queue.enqueue(
        id: 'p1',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async { executed = true; return true; }
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(executed, isFalse);

      queue.resume();
      await future;

      expect(executed, isTrue);
    });

    test('Epoch change cancels stale tasks', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);
      bool oldTaskExecuted = false;
      bool newTaskExecuted = false;

      queue.pause();

      final f1 = queue.enqueue(
        id: 'old_task',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async { oldTaskExecuted = true; return 'old'; }
      );

      // Cancel stale tasks for epoch 2
      queue.cancelStaleTasks(2);

      final f2 = queue.enqueue(
        id: 'new_task',
        currentEpoch: 2,
        priority: TaskPriority.normal,
        action: () async { newTaskExecuted = true; return 'new'; }
      );

      queue.resume();

      await Future.wait([f1 as Future<dynamic>, f2 as Future<dynamic>]);

      expect(oldTaskExecuted, isFalse);
      expect(newTaskExecuted, isTrue);
    });

    test('Epoch change cancels actively running stale tasks', () async {
       final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);
       bool isCancelled = false;
       final token = CancellationToken();

       queue.enqueue(
          id: 'long_running',
          currentEpoch: 1,
          priority: TaskPriority.normal,
          token: token,
          action: () async {
             await Future.delayed(const Duration(milliseconds: 100));
             isCancelled = token.isCancelled;
             return 'done';
          }
       );

       // Allow task to start running
       await Future.delayed(const Duration(milliseconds: 10));

       queue.cancelStaleTasks(2); // this should cancel the token

       await Future.delayed(const Duration(milliseconds: 150));
       expect(isCancelled, isTrue);
    });

    test('WorkerTask execution handles timeout correctly', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);

      final workerTask = WorkerTask<String>(
        taskId: 'timeout_task',
        timeout: const Duration(milliseconds: 50),
        execute: (token) async {
          await Future.delayed(const Duration(milliseconds: 200));
          token.throwIfCancelled();
          return 'done';
        }
      );

      final future = queue.enqueueWorkerTask(
        currentEpoch: 1,
        priority: TaskPriority.normal,
        task: workerTask
      );

      expect(
        () async => await future,
        throwsA(isA<TimeoutException>())
      );
    });

    test('Clear cancels all tasks', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);
      bool executed = false;
      final token = CancellationToken();

      queue.pause();
      queue.enqueue(
        id: 'c1',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        token: token,
        action: () async { executed = true; return true; }
      );

      queue.clear();
      expect(queue.length, 0);
      expect(token.isCancelled, isTrue);

      queue.resume();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(executed, isFalse);
    });
  });
}
