import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  group('PersistentCpuWorker (J013)', () {
    late PersistentCpuWorker worker;

    setUp(() {
      worker = PersistentCpuWorker(maxQueueSize: 5, maxConcurrentTasks: 2);
    });

    test('executes a single task successfully', () async {
      final result = await worker.executeTask(
        computation: () async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return 42;
        },
      );
      expect(result, 42);
    });

    test('throws WorkerQueueExhaustedException when queue is full', () async {
      final completers = <Completer<void>>[];
      for (var i = 0; i < 5; i++) {
        final c = Completer<void>();
        completers.add(c);
        unawaited(worker.executeTask(
          computation: () => c.future,
        ));
      }

      // The queue and active tasks should now total 5 (maxQueueSize)
      // Attempting one more should throw
      expect(
        () => worker.executeTask(
          computation: () async => 1,
        ),
        throwsA(isA<WorkerQueueExhaustedException>()),
      );

      for (final c in completers) {
        c.complete();
      }
    });

    test('enforces concurrency limit', () async {
      int active = 0;
      int maxActive = 0;

      Future<void> simulatedTask() async {
        active++;
        if (active > maxActive) {
          maxActive = active;
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
        active--;
      }

      final futures = <Future<void>>[];
      for (var i = 0; i < 5; i++) {
        futures.add(worker.executeTask(
          computation: simulatedTask,
        ));
      }

      await Future.wait(futures);
      expect(maxActive, 2); // maxConcurrentTasks
    });

    test('returns null for stale generations due to cancellation', () async {
      final future1 = worker.executeTask(
        computation: () async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return 1;
        },
      );

      final future2 = worker.executeTask(
        computation: () async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return 2;
        },
      );

      // Cancel before completion
      worker.cancelActiveOperations();

      final result1 = await future1;
      final result2 = await future2;

      expect(result1, isNull);
      expect(result2, isNull);
    });

    test('propagates errors safely without crashing', () async {
      final future = worker.executeTask(
        computation: () async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          throw Exception('Task Failed');
        },
      );

      await expectLater(future, throwsException);
    });

    test('throws StateError when scheduling on disposed worker', () async {
      worker.dispose();
      expect(worker.isDisposed, isTrue);

      expect(
        () => worker.executeTask(computation: () async => 1),
        throwsStateError,
      );
    });

    test('disposal returns null for active and queued tasks', () async {
      final future1 = worker.executeTask(
        computation: () async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return 1;
        },
      );

      final future2 = worker.executeTask(
        computation: () async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return 2;
        },
      );

      // Enqueued tasks
      final future3 = worker.executeTask(
        computation: () async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return 3;
        },
      );

      worker.dispose();

      expect(await future1, isNull);
      expect(await future2, isNull);
      expect(await future3, isNull);
    });

    test('timeout throws and returns null if not handled by test', () async {
      // Create a worker with a very short timeout
      final shortWorker =
          PersistentCpuWorker(maxQueueSize: 5, maxConcurrentTasks: 2);

      final future = shortWorker.executeTask(
        computation: () async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          return 'done';
        },
        timeout: const Duration(milliseconds: 10),
      );

      await expectLater(future, throwsA(isA<TimeoutException>()));
    });

    test('stress test concurrent tasks within limits', () async {
      final worker2 =
          PersistentCpuWorker(maxQueueSize: 55, maxConcurrentTasks: 2);
      final futures = <Future<int?>>[];
      for (var i = 0; i < 50; i++) {
        futures.add(worker2.executeTask(
          computation: () async {
            await Future<void>.delayed(const Duration(milliseconds: 2));
            return i;
          },
        ));
      }

      final results = await Future.wait(futures);
      expect(results.length, 50);
      for (var i = 0; i < 50; i++) {
        expect(results[i], i);
      }
    });
  });
}
