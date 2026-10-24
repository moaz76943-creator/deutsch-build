import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PersistentCpuWorker.resetForTesting();
  });

  test('Expensive tasks use the existing isolated worker boundary and complete successfully', () async {
    final worker = PersistentCpuWorker.instance;
    final ease = await worker.calculateNewEaseFactor(2.5, 4);
    expect(ease, isA<double>());
    expect(ease, greaterThanOrEqualTo(1.3));
  });

  test('Queue capacity is enforced', () async {
    final worker = PersistentCpuWorker.instance;

    bool threwExhaustion = false;
    final futures = <Future>[];
    for (int i = 0; i < worker.maxQueueSize; i++) {
      futures.add(worker.executeTask<Map<String, dynamic>, double>(
          _slowTask, {'ease': 2.5, 'rating': 3}).catchError((_) => 0.0));
    }

    try {
      await worker.executeTask<Map<String, dynamic>, double>(
          _slowTask, {'ease': 2.5, 'rating': 3});
    } on WorkerQueueExhaustedException {
      threwExhaustion = true;
    }

    expect(threwExhaustion, isTrue);
    worker.cancelAll();
    await Future.wait(futures);
  });

  test('Cancellation is enforced and no stale task result overwrites', () async {
    final worker = PersistentCpuWorker.instance;
    final f1 = worker.executeTask<Map<String, dynamic>, double>(
          _slowTask, {'ease': 2.5, 'rating': 3});

    worker.cancelAll();
    expect(() async => await f1, throwsA(isA<WorkerCancelledException>()));
  });

  test('Worker errors are handled gracefully without crashing', () async {
    final worker = PersistentCpuWorker.instance;
    final f = worker.executeTask<Map<String, dynamic>, double>(
          _errorTask, {'ease': 2.5, 'rating': 3});

    expect(() async => await f, throwsException);
  });

  test('Stress test: concurrent SRS calculations', () async {
    final worker = PersistentCpuWorker.instance;
    final futures = <Future<double>>[];

    for (int i = 0; i < 50; i++) {
      futures.add(worker.calculateNewEaseFactor(2.5, 3));
    }

    final results = await Future.wait(futures);
    expect(results.length, 50);
    for (var r in results) {
      expect(r, isA<double>());
    }
  });

  test('Lifecycle pause cancels tasks', () async {
    final worker = PersistentCpuWorker.instance;
    final f1 = worker.executeTask<Map<String, dynamic>, double>(
          _slowTask, {'ease': 2.5, 'rating': 3});

    worker.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(() async => await f1, throwsA(isA<WorkerCancelledException>()));
  });
}

double _slowTask(dynamic rawData) {
  sleep(const Duration(milliseconds: 10));
  return 2.0;
}

double _errorTask(dynamic rawData) {
  throw Exception('Worker Error');
}
