import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';
import 'package:flutter/widgets.dart';

void main() {
  late PersistentCpuWorker worker;

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
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

      // We need to exhaust the queue immediately, we should send tasks sync
      worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0);
      worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0);
      worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0);
      worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0);
      worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0);
      worker.calculateNewEaseFactor(2.5, 4).catchError((_) => 0.0);

      expect(() => worker.calculateNewEaseFactor(2.5, 4), throwsA(isA<WorkerQueueExhaustedException>()));
    });

    test('worker failure propagates correctly', () async {
      expect(
        () => worker.calculateNewEaseFactor(-1.0, 4),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('PersistentCpuWorker - Cancellation & Disposal', () {
    test('cancelCurrentGeneration rejects stale results', () async {
      final future = worker.calculateNewEaseFactor(2.5, 4);
      worker.cancelCurrentGeneration();
      await expectLater(future, throwsA(isA<WorkerCancelledException>()));
    });

    test('dispose cancels jobs and prevents new ones', () async {
      final future = worker.calculateNewEaseFactor(2.5, 4);
      worker.dispose();
      await expectLater(future, throwsA(isA<WorkerCancelledException>()));
      expect(() => worker.calculateNewEaseFactor(2.5, 4), throwsA(isA<StateError>()));
    });
  });

  group('PersistentCpuWorker - Stress Test', () {
    test('handles concurrent jobs up to bounds without crashing', () async {
      worker.setMaxQueueSize(100);

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
