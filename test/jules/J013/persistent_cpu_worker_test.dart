import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  setUp(() {
    PersistentCpuWorker.resetForTesting();
  });

  test('calculateNewEaseFactor executes correctly', () async {
    final worker = PersistentCpuWorker.instance;
    final ease = await worker.calculateNewEaseFactor(2.5, 4);
    expect(ease, isA<double>());
    expect(ease, closeTo(2.5, 0.01));
  });

  test('queue exhaustion throws exception', () async {
    final worker = PersistentCpuWorker.instance;
    // Max queue is 50, Max concurrent is 4
    // We submit 60 tasks
    int successCount = 0;
    int errorCount = 0;
    List<Future<double>> futures = [];
    for (int i = 0; i < 60; i++) {
      futures.add(worker.calculateNewEaseFactor(2.5, 4).then((double _) {
        successCount++;
        return _;
      }).catchError((Object e) {
        expect(e, isA<WorkerQueueExhaustedException>());
        errorCount++;
        return 0.0;
      }));
    }

    await Future.wait(futures);
    expect(successCount, 54); // 50 in queue + 4 active = 54
    expect(errorCount, 6);
  });

  test('cancellation rejects pending tasks with WorkerCancelledException', () async {
    final worker = PersistentCpuWorker.instance;
    List<Future<double>> futures = [];
    // Queue up several
    for (int i = 0; i < 10; i++) {
      // Need to catch errors on the futures immediately so they don't bubble up unhandled
      futures.add(worker.calculateNewEaseFactor(2.5, 4).catchError((Object e) {
        if (e is! WorkerCancelledException) throw e; // no cast needed
        return -1.0; // Return a dummy value to indicate cancellation
      }));
    }

    worker.cancelAll();

    int successCount = 0;
    int cancelCount = 0;

    for (var f in futures) {
      final result = await f;
      if (result == -1.0) {
        cancelCount++;
      } else {
        successCount++;
      }
    }

    expect(successCount + cancelCount, 10);
    expect(cancelCount, greaterThan(0));
  });

  test('error in task does not crash worker and propagates', () async {
    final worker = PersistentCpuWorker.instance;
    // We can test executing a raw task to test failures
    var future = worker.executeTask<Map<String, dynamic>, double>(
      _failingTask,
      {'test': 'test'}
    );

    try {
      await future;
      fail('Should have thrown');
    } catch (e) {
      expect(e.toString(), contains('Task Failed'));
    }

    // Worker should still be able to process other tasks
    final ease = await worker.calculateNewEaseFactor(2.5, 4);
    expect(ease, closeTo(2.5, 0.01));
  });

  test('bounded memory usage and queue limits', () async {
    final worker = PersistentCpuWorker.instance;
    int accepted = 0;
    int rejected = 0;
    List<Future<double>> futures = [];

    // We should not be able to submit more than maxQueueSize (50) + active tasks (4)
    // Send 1000 tasks
    for (int i = 0; i < 1000; i++) {
      futures.add(worker.calculateNewEaseFactor(2.5, 4).then((double _) {
        accepted++;
        return _;
      }).catchError((Object e) {
        if (e is WorkerQueueExhaustedException) {
          rejected++;
        }
        return 0.0;
      }));
    }

    await Future.wait(futures);
    expect(accepted, 54);
    expect(rejected, 946);
  });
}

double _failingTask(Map<String, dynamic> message) {
  throw Exception('Task Failed');
}
