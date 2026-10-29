import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/concurrency/isolated_task_queue.dart';
import 'package:deutsch_bilarabi/core/concurrency/cancellation_token.dart';

void main() {
  group('IsolatedTaskQueue Tests', () {
    late IsolatedTaskQueue queue;

    setUp(() {
      queue = IsolatedTaskQueue(maxQueueSize: 5, maxConcurrentTasks: 2);
    });

    test('enqueue respects maxQueueSize and drops low priority tasks', () async {
      queue.pause(); // Pause to fill the queue and test eviction accurately
      final futures = <Future>[];
      for (int i = 0; i < 5; i++) {
        futures.add(queue.enqueue(
          id: 'low_$i',
          currentEpoch: 1,
          priority: TaskPriority.low,
          action: () async => await Future.delayed(const Duration(milliseconds: 100)),
        ));
      }
      expect(queue.length + queue.activeTasks, 5);

      final highFuture = queue.enqueue(
        id: 'high_1',
        currentEpoch: 1,
        priority: TaskPriority.high,
        action: () async => 'high_res',
      );

      expect(queue.length + queue.activeTasks, 5);

      queue.resume(1);
      final res = await highFuture;
      expect(res, 'high_res');
    });

    test('deduplicates tasks with same id', () {
      int execCount = 0;
      final f1 = queue.enqueue(
        id: 'dup_id',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async {
          execCount++;
          await Future.delayed(const Duration(milliseconds: 50));
          return 'res';
        },
      );

      final f2 = queue.enqueue(
        id: 'dup_id',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async {
          execCount++;
          return 'res2';
        },
      );

      expect(identical(f1, f2), isTrue);
    });

    test('pauses and resumes cooperatively', () async {
      queue.pause();
      int completedCount = 0;

      queue.enqueue(
        id: 'p1',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async {
          completedCount++;
        },
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(completedCount, 0); // Still paused

      queue.resume(1);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(completedCount, 1); // Resumed and finished
    });

    test('cancels stale tasks gracefully', () async {
      queue.pause(); // keep them in queue
      queue.enqueue(
        id: 's1',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async => 's1',
      );
      queue.enqueue(
        id: 's2',
        currentEpoch: 2,
        priority: TaskPriority.normal,
        action: () async => 's2',
      );

      expect(queue.length, 2);
      queue.cancelStaleTasks(2);
      expect(queue.length, 1); // Task s1 from epoch 1 should be gone
    });

    test('respects CancellationToken', () async {
      final token = CancellationToken();
      bool wasExecuted = false;

      queue.pause();
      final future = queue.enqueue(
        id: 'c1',
        currentEpoch: 1,
        priority: TaskPriority.normal,
        action: () async {
          wasExecuted = true;
          return 'done';
        },
        cancellationToken: token,
      );

      token.cancel();
      queue.resume(1);

      final result = await future;
      expect(result, null);
      expect(wasExecuted, false);
    });

    test('concurrency limits are enforced', () async {
      int currentConcurrent = 0;
      int maxConcurrentFound = 0;

      Future<void> simulateWork() async {
        currentConcurrent++;
        if (currentConcurrent > maxConcurrentFound) maxConcurrentFound = currentConcurrent;
        await Future.delayed(const Duration(milliseconds: 50));
        currentConcurrent--;
      }

      final futures = <Future>[];
      for (int i = 0; i < 4; i++) {
        futures.add(queue.enqueue(
          id: 'w$i',
          currentEpoch: 1,
          priority: TaskPriority.normal,
          action: simulateWork,
        ));
      }

      await Future.wait(futures);
      expect(maxConcurrentFound, lessThanOrEqualTo(2));
    });
  });
}
