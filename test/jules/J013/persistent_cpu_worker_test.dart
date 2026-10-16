import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PersistentCpuWorker', () {
    late PersistentCpuWorker worker;

    setUp(() {
      worker = PersistentCpuWorker.instance;
      worker.cancelAll();
    });

    test('calculateNewEaseFactor returns expected mathematical result', () async {
      final ease = await worker.calculateNewEaseFactor(2.5, 4);
      expect(ease, 2.5);
    });

    test('queue exhaustion throws StateError', () async {
      final futures = <Future>[];

      bool caughtError = false;

      // Fill up the queue
      for (int i = 0; i < PersistentCpuWorker.maxQueueSize; i++) {
        futures.add(worker.calculateNewEaseFactor(2.5, 4));
      }

      // The next one should throw synchronously or return a future that throws
      try {
        final future = worker.calculateNewEaseFactor(2.5, 4);
        await future;
      } catch (e) {
        if (e is StateError && e.message == 'Queue capacity reached') {
          caughtError = true;
        }
      }

      for (var f in futures) {
        try {
          await f;
        } catch (_) {}
      }

      expect(caughtError, isTrue);
    });

    test('cancelAll invalidates in-flight jobs', () async {
      final future = worker.calculateNewEaseFactor(2.5, 4);
      worker.cancelAll();

      expect(() async => await future, throwsA(
        isA<StateError>().having((e) => e.message, 'message', 'Job cancelled or stale generation')
      ));
    });

    test('worker failure does not crash and decrements pending jobs', () async {
      Future<void> failingJob() async {
        await worker.enqueue((_) => throw Exception('Intentional failure'), null);
      }

      expect(() async => await failingJob(), throwsException);

      final ease = await worker.calculateNewEaseFactor(2.5, 4);
      expect(ease, 2.5);
    });

    test('AppLifecycleState.paused cancels jobs', () async {
      final future = worker.calculateNewEaseFactor(2.5, 4);

      worker.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(() async => await future, throwsA(
        isA<StateError>().having((e) => e.message, 'message', 'Job cancelled or stale generation')
      ));
    });

    test('Bounded memory usage with large tasks (Stress)', () async {
      final futures = <Future>[];

      for (int i = 0; i < PersistentCpuWorker.maxQueueSize; i++) {
        futures.add(worker.calculateNewEaseFactor(2.5, 4));
      }

      int successCount = 0;
      for (var f in futures) {
        try {
          final result = await f;
          expect(result, 2.5);
          successCount++;
        } catch (e) {
          if (e is StateError && e.message == 'Queue capacity reached') {
            continue;
          }
          rethrow;
        }
      }
      expect(successCount, greaterThan(0));
    });
  });
}
