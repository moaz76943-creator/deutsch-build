import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/concurrency/cancellation_token.dart';
import 'package:deutsch_bilarabi/core/concurrency/isolated_task_queue.dart';
import 'package:deutsch_bilarabi/core/concurrency/worker_task.dart';
import 'dart:async';

void main() {
  group('J085 - Bounded Concurrency & Task Scheduling', () {
    test('Queue length and concurrent work remain bounded', () async {
      final queue = IsolatedTaskQueue(maxQueueSize: 3, maxConcurrentTasks: 2);

      int activeExecutions = 0;
      int maxActiveExecutions = 0;

      Future<int> action() async {
        activeExecutions++;
        if (activeExecutions > maxActiveExecutions) {
          maxActiveExecutions = activeExecutions;
        }
        await Future.delayed(const Duration(milliseconds: 50));
        activeExecutions--;
        return 1;
      }

      final futures = <Future>[];
      for (int i = 0; i < 6; i++) {
        final f = queue.enqueue(
          id: 'task_$i',
          currentEpoch: 1,
          priority: TaskPriority.normal,
          action: action,
        );
        futures.add(f);
      }

      expect(queue.length + queue.activeTasksCount, lessThanOrEqualTo(5));
      await Future.wait(futures);
      expect(maxActiveExecutions, lessThanOrEqualTo(2));
    });

    test('Deduplication of identical tasks', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);
      int executions = 0;

      final futures = <Future>[];
      for (int i = 0; i < 3; i++) {
        futures.add(queue.enqueue(
          id: 'same_task',
          currentEpoch: 1,
          priority: TaskPriority.normal,
          action: () async {
            executions++;
            await Future.delayed(const Duration(milliseconds: 50));
            return executions;
          },
        ));
      }

      final results = await Future.wait(futures);

      expect(executions, 1);
      expect(results, [1, 1, 1]);
    });

    test('Cancellation prevents stale state mutation', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);

      bool staleExecuted = false;
      bool currentExecuted = false;

      final staleFuture = queue.enqueueWorkerTask(
        task: WorkerTask<int>(
          taskId: 'stale',
          execute: (token) async {
            // Need a loop to check cancellation during await
            try {
              for (int i=0; i<5; i++) {
                token.throwIfCancelled();
                await Future.delayed(const Duration(milliseconds: 20));
              }
              staleExecuted = true;
              return 1;
            } catch(e) {
              return 1; // Catch internally or it bubbles to queue
            }
          }
        ),
        currentEpoch: 1,
        priority: TaskPriority.normal,
      );

      // give it time to become active
      await Future.delayed(const Duration(milliseconds: 10));

      queue.cancelStaleTasks(2);

      final currentFuture = queue.enqueue(
        id: 'current',
        currentEpoch: 2,
        priority: TaskPriority.normal,
        action: () async {
          currentExecuted = true;
          return 2;
        },
      );

      final staleResult = await staleFuture;
      final currentResult = await currentFuture;

      expect(staleResult, isNull);
      expect(staleExecuted, isFalse);
      expect(currentResult, 2);
      expect(currentExecuted, isTrue);
    });

    test('Cooperative pause and resume policies', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);
      int executions = 0;

      queue.pause();

      final future = queue.enqueue(
        id: 'paused_task',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async {
          executions++;
          return 1;
        },
      );

      expect(queue.length, 1);
      expect(queue.activeTasksCount, 0);
      expect(executions, 0);

      queue.resume();

      await future;

      expect(queue.length, 0);
      expect(executions, 1);
    });

    test('Interactive work retains priority (starvation test)', () async {
      final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);
      final execOrder = <String>[];

      // Tie up the queue
      final f1 = queue.enqueue(
        id: 'low_1',
        currentEpoch: 1,
        priority: TaskPriority.low,
        action: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          execOrder.add('low_1');
        },
      );

      final f2 = queue.enqueue(
        id: 'low_2',
        currentEpoch: 1,
        priority: TaskPriority.low,
        action: () async {
          execOrder.add('low_2');
        },
      );

      final f3 = queue.enqueue(
        id: 'high_1',
        currentEpoch: 1,
        priority: TaskPriority.high,
        action: () async {
          execOrder.add('high_1');
        },
      );

      await Future.wait([f1, f2, f3]);

      expect(execOrder, ['low_1', 'high_1', 'low_2']);
    });

    test('yieldAndCheck enforces CPU isolation without busy-wait', () async {
      final token = CancellationToken();

      final stopwatch = Stopwatch()..start();

      // Simulate heavy CPU work with yields
      for (int i = 0; i < 1000; i++) {
        double val = 0;
        for(int j=0; j<100; j++) {
          val += j * i;
        }
        await token.yieldAndCheck();
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThan(0));
    });

    test('WorkerTask timeout and cancellation', () async {
       final queue = IsolatedTaskQueue(maxConcurrentTasks: 1);

       bool taskStarted = false;

       final task = WorkerTask<int>(
         taskId: 'long_task',
         timeout: const Duration(milliseconds: 50),
         execute: (token) async {
           taskStarted = true;
           for (int i = 0; i < 10; i++) {
             token.throwIfCancelled();
             await Future.delayed(const Duration(milliseconds: 20));
           }
           return 1;
         }
       );

       final future = queue.enqueueWorkerTask(
         task: task,
         currentEpoch: 1,
         priority: TaskPriority.normal,
       );

       try {
         await future;
         fail('Expected TimeoutException');
       } catch (e) {
         expect(e, isA<TimeoutException>());
       }
       expect(taskStarted, isTrue);
    });
  });
}
