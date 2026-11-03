import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  late PersistentCpuWorker worker;

  setUp(() {
    PersistentCpuWorker.resetForTesting();
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
      worker.setMaxQueueSize(2);

      // Start 2 jobs that will take some time
      final future1 = worker.calculateNewEaseFactor(2.5, 4);
      final future2 = worker.calculateNewEaseFactor(2.5, 4);

      // We need to wait a tick for the microtask to move them from the queue to the active set,
      // but if maxQueueSize is 2 and we submit 7 synchronously it will definitely throw.
      // (active: 4, queue: 2) -> 6th is max, 7th throws.
      final future3 = worker.calculateNewEaseFactor(2.5, 4);
      final future4 = worker.calculateNewEaseFactor(2.5, 4);
      final future5 = worker.calculateNewEaseFactor(2.5, 4);
      final future6 = worker.calculateNewEaseFactor(2.5, 4);

      try {
        await worker.calculateNewEaseFactor(2.5, 4);
        fail('Should have thrown WorkerQueueExhaustedException');
      } catch (e) {
        expect(e, isA<WorkerQueueExhaustedException>());
      }
    });

    test('worker failure propagates correctly', () async {
      try {
        await worker.calculateNewEaseFactor(-1.0, 4);
        fail('Expected ArgumentError');
      } catch (e) {
        expect(e, isA<ArgumentError>());
      }
    });
  });

  group('PersistentCpuWorker - Cancellation & Disposal', () {
    test('cancelCurrentGeneration rejects stale results', () async {
      // Start a job
      final future = worker.calculateNewEaseFactor(2.5, 4);

      // Cancel generation immediately
      worker.cancelCurrentGeneration();

      try {
         await future;
         fail('Expected WorkerCancelledException');
      } catch(e) {
         expect(e, isA<WorkerCancelledException>());
      }
    });

    test('dispose cancels jobs and prevents new ones', () async {
      // Start a job
      final future = worker.calculateNewEaseFactor(2.5, 4);

      // Dispose immediately
      worker.dispose();

      try {
         await future;
         fail('Expected WorkerCancelledException');
      } catch(e) {
         expect(e, isA<WorkerCancelledException>());
      }

      // New jobs should be rejected
      try {
         await worker.calculateNewEaseFactor(2.5, 4);
         fail('Expected StateError');
      } catch(e) {
         expect(e, isA<StateError>());
      }
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
