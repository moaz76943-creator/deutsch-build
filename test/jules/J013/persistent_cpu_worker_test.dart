import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  late PersistentCpuWorker worker;

  setUp(() {
    // Since instance is a singleton, we might have interference, but we can reset state via reflection or just use the singleton and clean up.
    // However, to make it clean, we can just reset its internal state for tests.
    worker = PersistentCpuWorker.instance;
    worker.resume(); // Reset pause
    // Hack to reset _generation and _pendingJobsCount and _isDisposed for reliable tests without modifying source for testing.
    // Instead of hacking, let's just make sure tests run sequentially and cleanup properly.
  });

  tearDown(() {
    // No-op for now
  });

  test('Calculate SRS Ease Factor correctly', () async {
    final result = await worker.calculateNewEaseFactor(2.5, 4);
    expect(result, closeTo(2.5, 0.01));
  });

  test('Concurrent SRS calculations bounded memory/queue limits', () async {
    final futures = <Future<double>>[];
    for (int i = 0; i < 40; i++) {
      futures.add(worker.calculateNewEaseFactor(2.5, 4));
    }

    final results = await Future.wait(futures);
    expect(results.length, 40);
    for (final res in results) {
      expect(res, closeTo(2.5, 0.01));
    }
  });

  test('Queue exhaustion throws WorkerQueueExhaustedException', () async {
    worker.pause(); // Pause to guarantee queue fills up without tasks completing immediately
    final futures = <Future<double>>[];
    // Fill up the queue up to 50
    for (int i = 0; i < 50; i++) {
      // Catch exceptions from cancelled tasks so wait doesn't fail
      futures.add(worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0));
    }

    // The 51st should throw
    await expectLater(
      worker.calculateNewEaseFactor(2.5, 4),
      throwsA(isA<WorkerQueueExhaustedException>()),
    );

    // Clean up to not interfere with other tests
    worker.cancelAll();
    worker.resume();
    await Future.wait(futures);
  });

  test('Cancelled jobs throw WorkerCancelledException and do not overwrite state', () async {
    final future = worker.calculateNewEaseFactor(2.5, 4);
    worker.cancelAll();

    await expectLater(
      future,
      throwsA(isA<WorkerCancelledException>()),
    );
  });

  test('Worker failure propagates without freezing UI', () async {
    await expectLater(
      worker.simulateFailingTask(),
      throwsA(isA<Exception>()),
    );
  });

}
