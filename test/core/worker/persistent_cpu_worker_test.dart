import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  group('PersistentCpuWorker Lifecycle & Concurrency Tests', () {
    late PersistentCpuWorker worker;

    setUp(() {
      worker = PersistentCpuWorker();
    });

    tearDown(() {
      worker.dispose();
    });

    test(
        'Enforces latest-wins policy: drops outdated task results when new generation starts',
        () async {
      // 1. Task 1 is slow (simulating heavy parsing)
      final task1 = worker.executeTask<String>(
        computation: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 'stale_result_from_task_1';
        },
      );

      // 2. Task 2 dispatched immediately after in the same flow (e.g. user typed new query)
      final task2 = worker.executeTask<String>(
        computation: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'fresh_result_from_task_2';
        },
      );

      final results = await Future.wait([task1, task2]);

      // Assert Task 1 result was dropped (null) while Task 2 succeeded
      expect(results[0], isNull);
      expect(results[1], equals('fresh_result_from_task_2'));
    });

    test('Explicit cancellation voids pending task without crashing worker',
        () async {
      final task = worker.executeTask<String>(
        computation: () async {
          await Future.delayed(const Duration(milliseconds: 40));
          return 'should_not_arrive';
        },
      );

      // Cancel immediately (e.g. user switched language pair)
      worker.cancelActiveOperations();

      final result = await task;
      expect(result, isNull);
    });

    test('Safe dispose prevents zombie executions and rejects new tasks',
        () async {
      worker.dispose();
      expect(worker.isDisposed, isTrue);

      expect(
        () => worker.executeTask<int>(computation: () async => 42),
        throwsA(isA<StateError>()),
      );
    });
  });
}
