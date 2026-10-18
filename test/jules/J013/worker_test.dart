import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';
import 'package:flutter/widgets.dart';

void main() {
  late PersistentCpuWorker worker;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    worker = PersistentCpuWorker.instance;
    worker.reset();
  });

  group('PersistentCpuWorker - Core Calculations', () {
    test('calculateNewEaseFactor returns expected value', () async {
      final newEase = await worker.calculateNewEaseFactor(2.5, 4);
      expect(newEase, isPositive);
    });

    test('calculateNewEaseFactor respects 1.3 minimum ease', () async {
      final newEase = await worker.calculateNewEaseFactor(1.1, 1);
      expect(newEase, 1.3);
    });
  });

  group('PersistentCpuWorker - Bounded Execution & Failures', () {
    test('throws WorkerQueueExhaustedException when queue is full', () async {
      // If maxQueueSize is 0, then we can only take maxConcurrentTasks (which is 4) jobs.
      worker.setMaxQueueSize(0);

      // Start 4 jobs that will become active
      final future1 = worker.calculateNewEaseFactor(2.5, 4);
      final future2 = worker.calculateNewEaseFactor(2.5, 4);
      final future3 = worker.calculateNewEaseFactor(2.5, 4);
      final future4 = worker.calculateNewEaseFactor(2.5, 4);

      // The 5th job should immediately throw due to queue exhaustion
      bool threw = false;
      try {
        await worker.calculateNewEaseFactor(2.5, 4);
      } catch (e) {
        threw = true;
        expect(e, isA<WorkerQueueExhaustedException>());
      }
      expect(threw, isTrue);

      // Wait for completion
      await Future.wait([future1, future2, future3, future4]);
    });

    test('worker failure propagates correctly', () async {
      bool threw = false;
      try {
        await worker.calculateNewEaseFactor(-1.0, 4);
      } catch (e) {
        threw = true;
        expect(e, isA<ArgumentError>());
      }
      expect(threw, isTrue);
    });
  });

  group('PersistentCpuWorker - Cancellation & Disposal', () {
    test('cancelCurrentGeneration rejects stale results', () async {
      // Start a job
      final future = worker.calculateNewEaseFactor(2.5, 4);

      // Cancel generation immediately
      worker.cancelCurrentGeneration();

      // The job should complete but throw WorkerCancelledException before returning
      bool threw = false;
      try {
        await future;
      } catch (e) {
        threw = true;
        expect(e, isA<WorkerCancelledException>());
      }
      expect(threw, isTrue);
    });

    test('dispose cancels jobs and prevents new ones', () async {
      // Start a job
      final future = worker.calculateNewEaseFactor(2.5, 4);

      // Dispose immediately
      worker.dispose();

      // The running job should be cancelled
      bool threw = false;
      try {
        await future;
      } catch (e) {
        threw = true;
        expect(e, isA<WorkerCancelledException>());
      }
      expect(threw, isTrue);

      // New jobs should be rejected
      threw = false;
      try {
        await worker.calculateNewEaseFactor(2.5, 4);
      } catch (e) {
        threw = true;
        expect(e, isA<StateError>());
      }
      expect(threw, isTrue);
    });
  });

  group('PersistentCpuWorker - Stress Test', () {
    test('handles concurrent jobs up to bounds without crashing', () async {
      worker.setMaxQueueSize(100);

      // Create 100 concurrent valid jobs
      final List<Future<double>> futures = [];
      for (int i = 0; i < 100; i++) {
        futures.add(worker.calculateNewEaseFactor(2.5, 4));
      }

      final results = await Future.wait(futures);

      expect(results.length, 100);
      for (final result in results) {
        expect(result, isPositive);
      }
    });
  });
}
