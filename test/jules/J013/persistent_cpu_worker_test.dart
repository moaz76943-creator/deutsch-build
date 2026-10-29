import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

double dummyTask(Map<String, dynamic> data) {
  return data['value'] * 2.0;
}

double slowTask(Map<String, dynamic> data) {
  int ms = data['ms'] ?? 100;
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {}
  return 1.0;
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PersistentCpuWorker.resetForTesting();
  });

  tearDown(() {
    PersistentCpuWorker.instance.dispose();
  });

  test('Worker successfully processes a task', () async {
    final result = await PersistentCpuWorker.instance.executeTask<Map<String, dynamic>, double>(
      dummyTask,
      {'value': 21.0}
    );
    expect(result, 42.0);
  });

  test('Worker respects max queue size and throws WorkerQueueExhaustedException', () async {
    final worker = PersistentCpuWorker.instance;
    int successCount = 0;
    int exhaustCount = 0;

    final futures = <Future<double>>[];
    for (int i = 0; i < 60; i++) {
      final f = worker.executeTask<Map<String, dynamic>, double>(slowTask, {'ms': 100}).catchError((e) {
        if (e is WorkerQueueExhaustedException) {
          exhaustCount++;
          return 0.0;
        }
        throw e;
      });
      futures.add(f);
    }

    for (final f in futures) {
      final result = await f;
      if (result != 0.0) {
        successCount++;
      }
    }

    expect(successCount, 54);
    expect(exhaustCount, 6);

    worker.cancelAll();

    // Wait for futures so they don't leak
    for (final f in futures) {
      try { await f; } catch (_) {}
    }
  });


  test('Worker executes heavy SRS math correctly', () async {
    final result = await PersistentCpuWorker.instance.calculateNewEaseFactor(2.5, 4);
    // 2.5 + (0.1 - (5-4)*(0.08 + 1*0.02)) = 2.5 + (0.1 - 1*0.1) = 2.5 + 0 = 2.5
    expect(result, 2.5);
  });

  test('Worker stress test: large amount of concurrent tasks', () async {
    final worker = PersistentCpuWorker.instance;
    final futures = <Future<double>>[];

    // Max queue is 50, concurrent is 4. Add exactly 54.
    for (int i = 0; i < 54; i++) {
      final f = worker.calculateNewEaseFactor(2.5, 4);
      futures.add(f);
    }

    final results = await Future.wait(futures);
    expect(results.length, 54);
    expect(results.every((r) => r == 2.5), isTrue);
  });

  test('Worker failure test: task throws exception', () async {
    final worker = PersistentCpuWorker.instance;
    final f = worker.executeTask<Map<String, dynamic>, double>(
      (msg) => throw Exception('Intentional failure'),
      {}
    );
    expect(() => f, throwsException);
  });
  test('Worker cancels all tasks on request', () async {
    final worker = PersistentCpuWorker.instance;
    final futures = <Future<double>>[];
    for (int i = 0; i < 10; i++) {
      final f = worker.executeTask<Map<String, dynamic>, double>(slowTask, {'ms': 200});
      // Catch immediately to prevent unhandled async exceptions
      f.catchError((_) => 0.0);
      futures.add(f);
    }

    worker.cancelAll();

    int cancelCount = 0;
    for (final f in futures) {
      try {
        await f;
      } catch (e) {
        if (e is WorkerCancelledException) {
          cancelCount++;
        }
      }
    }

    expect(cancelCount, futures.length);
  });

  test('Worker cancels all tasks on application pause', () async {
    final worker = PersistentCpuWorker.instance;
    final futures = <Future<double>>[];
    for (int i = 0; i < 5; i++) {
      final f = worker.executeTask<Map<String, dynamic>, double>(slowTask, {'ms': 200});
      f.catchError((_) => 0.0);
      futures.add(f);
    }

    // Simulate app pause
    worker.didChangeAppLifecycleState(AppLifecycleState.paused);

    int cancelCount = 0;
    for (final f in futures) {
      try {
        await f;
      } catch (e) {
        if (e is WorkerCancelledException) {
          cancelCount++;
        }
      }
    }

    expect(cancelCount, futures.length);
  });
}
