import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  late PersistentCpuWorker worker;

  setUp(() {
    worker = PersistentCpuWorker.instance;
    PersistentCpuWorker.resetForTesting();
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
      final future1 = worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0);
      final future2 = worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0);

      // The 3rd job should immediately throw due to queue exhaustion
      expect(() => worker.calculateNewEaseFactor(2.5, 4), throwsA(isA<WorkerQueueExhaustedException>()));

      // Wait for completion
      await Future.wait([future1, future2]);
    });

    test('worker failure propagates correctly', () async {
      expect(
        () => worker.calculateNewEaseFactor(-1.0, 4),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('PersistentCpuWorker - Cancellation & Disposal', () {
    test('cancelAll rejects stale results', () async {
      // Start a job
      final future = worker.calculateNewEaseFactor(2.5, 4);

      // Cancel generation immediately
      worker.cancelAll();

      // The job should complete but throw WorkerCancelledException before returning
      expect(() => future, throwsA(isA<WorkerCancelledException>()));
    });

    test('dispose cancels jobs and prevents new ones', () async {
      // Start a job
      final future = worker.calculateNewEaseFactor(2.5, 4);

      // Dispose immediately
      worker.dispose();

      // The running job should be cancelled
      expect(() => future, throwsA(isA<WorkerCancelledException>()));

      // New jobs should be rejected
      expect(() => worker.calculateNewEaseFactor(2.5, 4), throwsA(isA<StateError>()));
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
