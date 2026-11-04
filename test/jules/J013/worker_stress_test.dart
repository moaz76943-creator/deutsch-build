import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PersistentCpuWorker.resetForTesting();
  });

  tearDown(() {
    PersistentCpuWorker.instance.dispose();
  });

  test('Calculate ease executes successfully', () async {
    final result =
        await PersistentCpuWorker.instance.calculateNewEaseFactor(2.5, 4);
    expect(result, isNotNull);
  });

  test('Queue exhausted exception is thrown when adding too many tasks',
      () async {
    final worker = PersistentCpuWorker.instance;
    final List<Future<double>> futures = [];

    // Default queue is 50, and 4 max concurrent.
    // Fill the queue and concurrent tasks to trigger queue exhausted
    bool exceptionThrown = false;
    for (int i = 0; i < 60; i++) {
      try {
        final future = worker.calculateNewEaseFactor(2.5, 4);
        futures.add(future.catchError((e) {
          if (e is WorkerQueueExhaustedException) {
            exceptionThrown = true;
          }
          return 0.0;
        }));
      } catch (e) {
        if (e is WorkerQueueExhaustedException) {
          exceptionThrown = true;
        }
      }
    }

    // Wait for microtasks
    await Future.microtask(() {});

    expect(exceptionThrown, true,
        reason: 'Expected WorkerQueueExhaustedException');

    worker
        .cancelAll(); // Cleanup queue so no unhandled completions run after tearDown

    for (final f in futures) {
      try {
        await f;
      } catch (_) {}
    }
  });

  test('Cancellation throws WorkerCancelledException', () async {
    final worker = PersistentCpuWorker.instance;

    final future = worker.calculateNewEaseFactor(2.5, 4);
    worker.cancelAll();

    try {
      await future;
      fail('Expected WorkerCancelledException');
    } catch (e) {
      expect(e, isA<WorkerCancelledException>());
    }
  });

  test('Concurrent SRS calculations succeed', () async {
    final worker = PersistentCpuWorker.instance;
    final List<Future<double>> futures = [];

    for (int i = 0; i < 10; i++) {
      futures.add(worker.calculateNewEaseFactor(2.5, 4));
    }

    final results = await Future.wait(futures);
    expect(results.length, 10);
    expect(results.every((element) => element > 0), true);
  });

  test('Worker failure throws generic exception', () async {
    final worker = PersistentCpuWorker.instance;

    // Create an invalid input that will cause a cast exception in heavySrsMath
    try {
      await worker.executeTaskWithPayload<Map<String, dynamic>, double>((data) {
        // Intentional cast error
        data['invalid'] as int;
        return 0.0;
      }, {'invalid': 'string_value'});
      fail('Expected an exception');
    } catch (e) {
      expect(e, isNot(isA<WorkerCancelledException>()));
    }
  });
}
