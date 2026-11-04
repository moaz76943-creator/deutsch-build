import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  late PersistentCpuWorker worker;

  setUp(() {
    PersistentCpuWorker.resetForTesting();
    worker = PersistentCpuWorker.instance;
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
      // The queue size is 50, and max concurrent tasks is 4.
      // So if we queue 55, the last ones will throw WorkerQueueExhaustedException.

      List<Future<double>> futures = [];
      bool caught = false;
      for (int i = 0; i < 100; i++) {
        final f = worker.calculateNewEaseFactor(2.5, 4);
        f.catchError((Object e) {
           if (e is WorkerQueueExhaustedException) caught = true;
           return 0.0;
        });
        futures.add(f);
      }

      for (var f in futures) {
        try {
           await f;
        } catch(e) {
          // Ignore expected exceptions in test loop
        }
      }
      expect(caught, true);

    });


  });

  group('PersistentCpuWorker - Cancellation & Disposal', () {
    test('cancelCurrentGeneration rejects stale results', () async {
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


      // Create 100 concurrent valid jobs
      final List<Future<double>> futures = [];
      for (int i = 0; i < 50; i++) {
        futures.add(worker.calculateNewEaseFactor(2.5, 4));
      }

      final results = await Future.wait(futures);

      expect(results.length, 50);
      for (final result in results) {
        expect(result, isPositive);
      }
    });
  });
}
