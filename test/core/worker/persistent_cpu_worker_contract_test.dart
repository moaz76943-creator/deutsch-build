import 'dart:async';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/worker/persistent_cpu_worker.dart';
import 'package:deutsch_bilarabi/core/worker/worker_contract.dart';

WorkerJob<Object?> job(String id, String type, Object? payload,
        {int epoch = 3}) =>
    WorkerJob<Object?>(id: id, type: type, epoch: epoch, payload: payload);

void main() {
  test('real typed jobs share one isolate and produce functional results',
      () async {
    final worker = await PersistentCpuWorker.start(initialEpoch: 3);
    addTearDown(worker.close);
    final decoded = await worker.submit<Map<Object?, Object?>>(job(
        'json', WorkerJobTypes.jsonDecode, {'encoded': '{"words":["مرحبا"]}'}));
    expect(decoded.status, WorkerStatuses.ok);
    expect(decoded.payload!['words'], ['مرحبا']);
    final hash = await worker
        .submit<String>(job('sha', WorkerJobTypes.sha256, {'content': 'abc'}));
    expect(hash.payload,
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
    final ranking = await worker
        .submit<List<Object?>>(job('rank', WorkerJobTypes.fuzzyRank, {
      'query': 'lernen',
      'candidates': [
        {'id': 'b', 'text': 'Buch'},
        {'id': 'a', 'text': 'lernen'},
      ],
      'limit': 1,
    }));
    expect((ranking.payload!.single as Map)['id'], 'a');
    expect(worker.spawnCount, 1);
  });

  test('epoch invalidates queued and running results without replay', () async {
    final worker = await PersistentCpuWorker.start(initialEpoch: 3);
    addTearDown(worker.close);
    final first = worker.submit<Object?>(
        job('first', WorkerJobTypes.jsonDecode, {'encoded': '{"old":true}'}));
    final second = worker.submit<Object?>(
        job('second', WorkerJobTypes.jsonDecode, {'encoded': '[1]'}));
    worker.advanceEpoch(4);
    for (final result in await Future.wait([first, second])) {
      expect(result.status, WorkerStatuses.stale);
      expect(result.payload, isNull);
    }
    final fresh = await worker.submit<Object?>(
        job('new', WorkerJobTypes.jsonDecode, {'encoded': '7'}, epoch: 4));
    expect(fresh.payload, 7);
  });

  test('named computation executes in the actual background isolate', () async {
    final worker = PersistentCpuWorker();
    addTearDown(worker.close);
    final name = await worker.executeTask<String?>(
        computation: () async => Isolate.current.debugName);
    expect(name, 'salim.cpu-worker');
  });

  test('timed out computation releases worker resources and allows recovery',
      () async {
    final worker = PersistentCpuWorker();
    addTearDown(worker.close);
    await expectLater(
        worker.executeTask<int>(
          computation: () async {
            await Future<void>.delayed(const Duration(seconds: 30));
            return 9;
          },
          timeout: const Duration(milliseconds: 30),
        ),
        throwsA(isA<TimeoutException>()));
    expect(worker.pendingJobs, 0);
    expect(await worker.executeTask<int>(computation: () async => 42), 42);
  });

  test('public typed data cannot request executable callbacks', () async {
    final worker = PersistentCpuWorker();
    addTearDown(worker.close);
    final result = await worker.submit<Object?>(job(
        'untrusted', 'internal.callback', {'function': () => 'must not run'},
        epoch: 0));
    expect(result.status, WorkerStatuses.error);
    expect(result.errorCode, 'unsupported_job_type');
    expect(worker.spawnCount, 0);
  });

  test('closing during startup settles requests and forbids new work',
      () async {
    final worker = PersistentCpuWorker();
    final pending = worker.executeTask<int>(computation: () async => 42);
    await worker.close();
    expect(await pending, isNull);
    expect(worker.isClosed, isTrue);
    await expectLater(
        worker.submit<Object?>(job(
            'closed', WorkerJobTypes.jsonDecode, {'encoded': '{}'},
            epoch: 0)),
        throwsStateError);
  });
}
