import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';

void main() {
  final worker = PersistentCpuWorker.instance;
  setUp(() => worker.reset());
  tearDown(() => worker.dispose());

  test('SRS math runs in a reused isolate', () async {
    final first = await worker.calculateNewEaseFactor(2.5, 4);
    final second = await worker.calculateNewEaseFactor(1.1, 1);
    expect(first, greaterThanOrEqualTo(1.3));
    expect(second, 1.3);
    expect(worker.workerStarts, 1);
    expect(worker.pendingJobs, 0);
  });

  test('invalid inputs do not poison the worker', () async {
    await expectLater(worker.calculateNewEaseFactor(-1, 3),
        throwsArgumentError);
    await expectLater(worker.calculateNewEaseFactor(2.5, 10),
        throwsArgumentError);
    expect(await worker.calculateNewEaseFactor(2.5, 4),
        greaterThanOrEqualTo(1.3));
  });

  test('bounded queue rejects excess work and releases all pending jobs',
      () async {
    worker.setMaxQueueSize(2);
    final first = worker.calculateNewEaseFactor(2.5, 4);
    final second = worker.calculateNewEaseFactor(2.5, 4);
    await expectLater(worker.calculateNewEaseFactor(2.5, 4),
        throwsA(isA<WorkerQueueExhaustedException>()));
    await Future.wait(<Future<double>>[first, second]);
    expect(worker.pendingJobs, 0);
  });

  test('pair switch rejects stale work and resumes with new generation',
      () async {
    final pending = worker.calculateNewEaseFactor(2.5, 4);
    final rejected = expectLater(
        pending, throwsA(isA<WorkerCancelledException>()));
    worker.cancelCurrentGeneration();
    await rejected;
    expect(worker.pendingJobs, 0);
    expect(await worker.calculateNewEaseFactor(2.5, 4),
        greaterThanOrEqualTo(1.3));
  });

  test('background pause invalidates work; resume admits new jobs', () async {
    final pending = worker.calculateNewEaseFactor(2.5, 4);
    final rejected = expectLater(
        pending, throwsA(isA<WorkerCancelledException>()));
    worker.didChangeAppLifecycleState(AppLifecycleState.paused);
    await rejected;
    worker.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(await worker.calculateNewEaseFactor(2.5, 4),
        greaterThanOrEqualTo(1.3));
  });

  test('dispose is idempotent and forbids new work', () async {
    final pending = worker.calculateNewEaseFactor(2.5, 4);
    final rejected = expectLater(
        pending, throwsA(isA<WorkerCancelledException>()));
    worker.dispose();
    worker.dispose();
    await rejected;
    await expectLater(worker.calculateNewEaseFactor(2.5, 4),
        throwsStateError);
  });

  test('concurrent isolate results do not exceed queue limits', () async {
    worker.setMaxQueueSize(64);
    final all = <Future<double>>[
      for (var i = 0; i < 64; i++)
        worker.calculateNewEaseFactor(2.5, 4),
    ];
    expect((await Future.wait(all)).length, 64);
    expect(worker.pendingJobs, 0);
    expect(worker.workerStarts, 1);
  });
}
