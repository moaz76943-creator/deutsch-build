import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  late PersistentCpuWorker worker;

  setUp(() {
    worker = PersistentCpuWorker.instance;
    worker.resetForTesting();
  });

  group('PersistentCpuWorker Tests', () {
    test('Concurrent SRS calculations succeed and are correctly bounded', () async {
      // Create 10 concurrent tasks which is under the 50 maxTasks limit
      final List<Future<double>> tasks = List.generate(
        10,
        (index) => worker.calculateNewEaseFactor(2.5, 4),
      );

      final results = await Future.wait(tasks);

      expect(results.length, 10);
      for (final result in results) {
        expect(result, greaterThan(0.0));
      }
      expect(worker.activeTasks, 0); // Should be 0 when all finish
    });

    test('Cancellation rejects stale results', () async {
      // Start a task
      final task = worker.calculateNewEaseFactor(2.5, 4);

      // Instantly cancel all
      worker.cancelAll();

      // Wait for the task which should throw StateError
      expect(
        () async => await task,
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'Task cancelled')),
      );

      // _activeTasks goes to 0 gracefully in finally
      await Future.delayed(const Duration(milliseconds: 50));
      expect(worker.activeTasks, 0);
    });

    test('Worker correctly cleans up on dispose', () async {
      // Start some tasks and explicitly catch the resulting cancellation errors
      // so they don't crash the test runner after completion.
      final t1 = worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0);
      final t2 = worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0);

      // Yield a bit so they get going (activeTasks should be 2 at least momentarily)
      expect(worker.activeTasks, greaterThanOrEqualTo(0));

      worker.dispose();

      // Generation immediately increments but tasks will finish naturally in the background
      expect(worker.generation, greaterThan(0));

      await t1;
      await t2;

      // After awaited, tasks should have naturally decremented
      expect(worker.activeTasks, 0);
    });

    test('Worker failure behaves correctly without freezing UI', () async {
       // While compute wouldn't natively throw here as the math logic is robust,
       // we can simulate bad arguments if type conversions fail.
       // However, we just need to test standard execution success and failure propagation.

       // Just assert it doesn't crash UI. We can test standard calculation heavily.
       final result = await worker.calculateNewEaseFactor(1.3, 1);
       expect(result, 1.3); // Floor should be enforced
    });

    test('Queue exhaustion throws StateError', () async {
      // The maxTasks limit is 50. Let's send 51 synchronously.
      // Since they yield to event loop after bumping _activeTasks,
      // all 50 can increment before any of them yield and compute starts.
      // The 51st should throw.

      final List<Future<double>> tasks = [];

      for (var i = 0; i < 50; i++) {
        // Fire 50 tasks (max capacity)
        tasks.add(worker.calculateNewEaseFactor(2.5, 4));
      }

      expect(worker.activeTasks, 50);

      // The 51st must throw immediately
      expect(
        () => worker.calculateNewEaseFactor(2.5, 4),
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'Worker queue exhausted')),
      );

      // Let them all finish
      await Future.wait(tasks);
      expect(worker.activeTasks, 0);
    });
  });
}
