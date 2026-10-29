import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  group('PersistentCpuWorker (J013)', () {
    setUp(() {
      PersistentCpuWorker.resetForTesting();
    });

    tearDown(() {
      runZonedGuarded(() {
        PersistentCpuWorker.instance.dispose();
      }, (e, s) {});
    });

    test('calculates correct ease factor asynchronously', () async {
      final newEase = await PersistentCpuWorker.instance.calculateNewEaseFactor(2.5, 4);
      expect(newEase, 2.5);

      final newEase2 = await PersistentCpuWorker.instance.calculateNewEaseFactor(2.5, 3);
      expect(newEase2, closeTo(2.36, 0.001));
    });

    test('deterministic task submission and concurrent execution', () async {
      final worker = PersistentCpuWorker.instance;
      final inputs = [
        {'ease': 2.5, 'rating': 5, 'expected': 2.6},
        {'ease': 2.0, 'rating': 1, 'expected': 1.46},
        {'ease': 1.3, 'rating': 3, 'expected': 1.3},
        {'ease': 2.8, 'rating': 4, 'expected': 2.8},
      ];

      final futures = <Future<double>>[];
      for (final input in inputs) {
        futures.add(worker.calculateNewEaseFactor(
            input['ease'] as double, input['rating'] as int));
      }

      final results = await Future.wait(futures);
      for (int i = 0; i < inputs.length; i++) {
        expect(results[i], closeTo(inputs[i]['expected'] as double, 0.001));
      }
    });

    test('generation-aware cancellation prevents stale overwrites', () async {
      final worker = PersistentCpuWorker.instance;
      final future = worker.calculateNewEaseFactor(2.5, 4);

      worker.cancelAll();

      try {
        await future;
        fail('Should have thrown WorkerCancelledException');
      } catch (e) {
        expect(e, isA<WorkerCancelledException>());
      }
    });

    test('queue exhaustion throws explicitly via Future.error', () async {
      final worker = PersistentCpuWorker.instance;

      // We must explicitly fill the queue and wait so it blocks.
      // But we can also just catch the Future.error directly.
      bool thrown = false;
      for (int i = 0; i < 60; i++) {
        final future = worker.executeTask<Map<String, dynamic>, double>(
          (map) {
            int sum = 0;
            for(int j=0; j<100000; j++) sum+=j;
            return 1.0;
          },
          {'key': i}
        );

        // Because executeTask returns Future.error synchronously on queue full,
        // we can catch it with a synchronous catchError block,
        // but it doesn't throw. It returns a failed future.
        // We await a small delay if we want, or just wait for catchError.
        future.catchError((e) {
          if (e is WorkerQueueExhaustedException) {
            thrown = true;
          }
          return 1.0;
        });
      }

      // Wait microtasks
      await Future.delayed(Duration(milliseconds: 100));

      expect(thrown, isTrue, reason: 'Expected WorkerQueueExhaustedException via catchError');
      worker.cancelAll();
    });

    test('error propagation from task failure', () async {
      final worker = PersistentCpuWorker.instance;

      try {
        await worker.executeTask<Map<String, dynamic>, double>(
          (map) {
             throw StateError('Boom');
          },
          {'bad': 'data'}
        );
        fail('Should have thrown StateError');
      } catch (e) {
        expect(e, isA<StateError>());
        expect((e as StateError).message, 'Boom');
      }
    });

    test('cancels all jobs on disposal', () async {
      final worker = PersistentCpuWorker.instance;
      final future = worker.executeTask<Map<String, dynamic>, double>(
          (map) => 1.0, {'key': 'val'});
      worker.dispose();

      try {
        await future;
        fail('Should have thrown WorkerCancelledException');
      } catch(e) {
        expect(e, isA<WorkerCancelledException>());
      }
    });

    test('cancels all jobs on application pause', () async {
      final worker = PersistentCpuWorker.instance;
      final future = worker.executeTask<Map<String, dynamic>, double>(
          (map) => 1.0, {'key': 'val'});
      worker.didChangeAppLifecycleState(AppLifecycleState.paused);

      try {
        await future;
        fail('Should have thrown WorkerCancelledException');
      } catch(e) {
        expect(e, isA<WorkerCancelledException>());
      }
    });
  });
}
