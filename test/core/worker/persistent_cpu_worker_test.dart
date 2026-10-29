import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  final worker = PersistentCpuWorker.instance;
  setUp(worker.reset);
  tearDown(worker.dispose);

  test('reuses the isolated worker for sequential and concurrent SRS jobs', () async {
    final first = await worker.calculateNewEaseFactor(2.5, 4);
    expect(first, closeTo(2.5, 0.00001));
    final results = await Future.wait(List.generate(
      25, (_) => worker.calculateNewEaseFactor(2.5, 1),
    ));
    expect(results.length, 25);
    expect(results.every((item) => item >= 1.3), isTrue);
    expect(worker.activeJobs, 0);
  });

  test('rejects queue overflow and releases slots after completion', () async {
    worker.setMaxQueueSize(1);
    final pending = worker.calculateNewEaseFactor(2.5, 3);
    await expectLater(worker.calculateNewEaseFactor(2.5, 3),
        throwsA(isA<WorkerQueueExhaustedException>()));
    await pending;
    expect(worker.activeJobs, 0);
    expect(await worker.calculateNewEaseFactor(2.5, 3), greaterThan(1.3));
  });

  test('cancellation invalidates old generation without replay', () async {
    final pending = worker.calculateNewEaseFactor(2.5, 4);
    worker.cancelCurrentGeneration();
    await expectLater(pending, throwsA(isA<WorkerCancelledException>()));
    expect(await worker.calculateNewEaseFactor(2.5, 4), isPositive);
  });

  test('dispose prevents new jobs and rejects invalid math', () async {
    await expectLater(worker.calculateNewEaseFactor(-1, 4),
        throwsA(isA<ArgumentError>()));
    await expectLater(worker.calculateNewEaseFactor(2.5, 9),
        throwsA(isA<ArgumentError>()));
    worker.dispose();
    await expectLater(worker.calculateNewEaseFactor(2.5, 4),
        throwsA(isA<StateError>()));
  });
  test('disposing during worker startup drains active jobs', () async {
    final pending = worker.calculateNewEaseFactor(2.5, 3);
    worker.dispose();
    await expectLater(pending, throwsA(anyOf(
      isA<WorkerCancelledException>(), isA<StateError>(),
    )));
    expect(worker.activeJobs, 0);
    worker.reset();
    expect(await worker.calculateNewEaseFactor(2.5, 3), greaterThan(1.3));
  });

}
