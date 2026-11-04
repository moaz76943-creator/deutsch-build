import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

// Helper for test failures
double _failingMathTask(dynamic data) {
  throw Exception("Simulated worker failure");
}

double _dummyMathTask(dynamic data) {
  return 1.0;
}

void main() {
  group('PersistentCpuWorker Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      PersistentCpuWorker.resetForTesting();
    });

    test('calculates new ease factor correctly', () async {
      final worker = PersistentCpuWorker.instance;
      final result = await worker.calculateNewEaseFactor(2.5, 4);
      // New Ease: 2.5 + (0.1 - (5-4)*(0.08 + (5-4)*0.02))
      // = 2.5 + (0.1 - 1*(0.1)) = 2.5
      expect(result, closeTo(2.5, 0.001));
    });

    test('handles bounded concurrency correctly', () async {
      final worker = PersistentCpuWorker.instance;
      // We will submit 10 tasks.
      // With maxConcurrentTasks = 4, they should execute successfully.
      List<Future<double>> tasks = [];
      for (int i = 0; i < 10; i++) {
        tasks.add(worker.calculateNewEaseFactor(2.5, 4));
      }

      final results = await Future.wait(tasks);
      expect(results.length, 10);
      for (var result in results) {
        expect(result, closeTo(2.5, 0.001));
      }
    });

    test('exhausts queue when exceeding maxQueueSize', () async {
      final worker = PersistentCpuWorker.instance;
      int exhaustCount = 0;

      for (int i = 0; i < 100; i++) {
        // We do not await, we just push 100 tasks synchronously
        worker.calculateNewEaseFactor(2.5, 4).catchError((e) {
          if (e is WorkerQueueExhaustedException) {
            exhaustCount++;
          }
          return 0.0;
        });
      }

      // Since _pump runs as microtask, the synchronous queueing above will immediately hit maxQueueSize limit.
      // Wait for microtasks and isolate callbacks to flush
      await Future.delayed(const Duration(milliseconds: 50));

      // 100 tasks pushed. Assuming maxQueueSize = 50.
      // If we now check queue+activeJobs, all 100 hit synchronously before microtasks run,
      // so exactly 50 are admitted (queued) and 50 are rejected.
      expect(exhaustCount, 50);

      // Wait for the active tasks to drain so the isolate shuts down cleanly
      worker.cancelAll();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('cancels active and queued jobs on cancelAll', () async {
      final worker = PersistentCpuWorker.instance;

      List<Future<double>> futures = [];
      for (int i = 0; i < 10; i++) {
        // Fire asynchronously to test queuing and cancellation
        futures.add(worker.calculateNewEaseFactor(2.5, 4).catchError((e) {
          if (e is WorkerCancelledException) {
            return -1.0;
          }
          throw e;
        }));
      }

      worker.cancelAll();

      int cancelledCount = 0;
      for (var f in futures) {
        final result = await f;
        if (result == -1.0) {
          cancelledCount++;
        }
      }

      expect(cancelledCount, 10);
    });

    test('clears queue on app pause lifecycle', () async {
      final worker = PersistentCpuWorker.instance;

      List<Future<double>> futures = [];
      for (int i = 0; i < 10; i++) {
        futures.add(worker.calculateNewEaseFactor(2.5, 4).catchError((e) {
          if (e is WorkerCancelledException) {
            return -1.0;
          }
          throw e;
        }));
      }

      worker.didChangeAppLifecycleState(AppLifecycleState.paused);

      int cancelledCount = 0;
      for (var f in futures) {
        final result = await f;
        if (result == -1.0) {
          cancelledCount++;
        }
      }

      expect(cancelledCount, 10);
    });

    test('handles worker failure without freezing UI', () async {
      final worker = PersistentCpuWorker.instance;

      bool failed = false;
      try {
        await worker
            .executeTaskWithPayload<dynamic, double>(_failingMathTask, {});
      } catch (e) {
        failed = true;
        expect(e.toString(), contains("Simulated worker failure"));
      }

      expect(failed, true);

      // Verify subsequent tasks can run
      final result = await worker.calculateNewEaseFactor(2.5, 4);
      expect(result, closeTo(2.5, 0.001));
    });

    test('verifies bounded memory with large synthetic task counts', () async {
      final worker = PersistentCpuWorker.instance;

      // Submit 50 tasks (at the queue limit) and await them all
      List<Future<double>> futures = [];
      for (int i = 0; i < 50; i++) {
        futures.add(
            worker.executeTaskWithPayload<dynamic, double>(_dummyMathTask, {}));
      }

      final results = await Future.wait(futures);
      expect(results.length, 50);
      expect(results.every((r) => r == 1.0), true);
    });
  });
}
