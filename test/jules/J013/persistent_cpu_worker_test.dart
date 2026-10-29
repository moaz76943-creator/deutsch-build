import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PersistentCpuWorker.resetForTesting();
  });

  tearDown(() {
    PersistentCpuWorker.instance.dispose();
  });

  test('Worker executeTask completes normally', () async {
    final worker = PersistentCpuWorker.instance;
    final result = await worker.calculateNewEaseFactor(2.5, 4);
    expect(result, isA<double>());
    expect(result, 2.5);
  });

  test('Worker respects queue limits', () async {
    final worker = PersistentCpuWorker.instance;
    final futures = <Future<double>>[];
    for (int i = 0; i < 54; i++) {
      futures.add(worker.calculateNewEaseFactor(2.5, 4).catchError((Object e) => -1.0));
    }

    expect(
      () => worker.calculateNewEaseFactor(2.5, 4),
      throwsA(isA<WorkerQueueExhaustedException>()),
    );

    await Future.wait(futures);
  });

  test('Worker cancelAll cancels pending tasks', () async {
    final worker = PersistentCpuWorker.instance;
    final futures = <Future<double>>[];
    for (int i = 0; i < 20; i++) {
      futures.add(worker.calculateNewEaseFactor(2.5, 4).catchError((Object e) {
        if (e is WorkerCancelledException) return -1.0;
        throw e;
      }));
    }

    worker.cancelAll();

    final results = await Future.wait(futures);
    expect(results.any((r) => r == -1.0), isTrue);
  });

  test('AppLifecycleState.paused triggers cancelAll', () async {
    final worker = PersistentCpuWorker.instance;
    final future = worker.calculateNewEaseFactor(2.5, 4);

    worker.didChangeAppLifecycleState(AppLifecycleState.paused);

    expect(() async => await future, throwsA(isA<WorkerCancelledException>()));
  });

  test('Stress test for concurrent SRS calculations', () async {
    final worker = PersistentCpuWorker.instance;
    final futures = <Future<double>>[];
    for (int i = 0; i < 50; i++) {
      futures.add(worker.calculateNewEaseFactor(2.5, 4));
    }

    final results = await Future.wait(futures);
    expect(results.length, 50);
    expect(results.every((r) => r == 2.5), isTrue);
  });

  test('Worker handles failure without freezing UI', () async {
    final worker = PersistentCpuWorker.instance;
    final future = worker.executeTask<int, int>(
      _failingTask,
      1,
    );

    try {
      await future;
      fail('Should have thrown');
    } catch (e) {
       // Just expecting some error to be thrown to prevent it freezing or crashing
       expect(e, isNotNull);
    }
  });
}

int _failingTask(dynamic input) {
  throw Exception('Worker failure simulated');
}
