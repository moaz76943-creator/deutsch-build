import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';
import 'package:flutter/widgets.dart';

void main() {
  late PersistentCpuWorker worker;

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
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

      // Four running jobs and two pending jobs saturate the bounded queue.
      // Await accepted jobs so they cannot leak into the next test.
      final accepted = <Future<double>>[];
      for (var i = 0; i < 6; i++) {
        accepted.add(worker.calculateNewEaseFactor(2.5, 4));
      }

      await expectLater(
        worker.calculateNewEaseFactor(2.5, 4),
        throwsA(isA<WorkerQueueExhaustedException>()),
      );
      await Future.wait(accepted);
    });

    test('worker failure propagates correctly', () async {
      await expectLater(
        worker.calculateNewEaseFactor(-1.0, 4),
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
      await expectLater(
        worker.calculateNewEaseFactor(2.5, 4),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('PersistentCpuWorker - Stress Test', () {
    test('handles concurrent jobs up to bounds without crashing', () async {


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
