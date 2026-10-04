import 'dart:io';
import 'dart:isolate';

import '../../../lib/core/storage/validation_hash_cache.dart';
import '../../../lib/core/worker/persistent_cpu_worker.dart';
import '../../../lib/core/worker/worker_contract.dart';

Future<void> main() async {
  await _typedContractsExposeOnlyRequiredIdentity();
  await _persistentWorkerExecutesCpuOperations();
  await _pairSwitchDropsQueuedJobs();
  await _unsendablePayloadDoesNotStallQueue();
  await _workerClosesSafely();
  await _runtimeOwnsOneWorkerAndRejectsStaleResults();
}

Future<void> _typedContractsExposeOnlyRequiredIdentity() async {
  const job = WorkerJob<Map<String, Object?>>(
    id: 'job-1',
    type: WorkerJobTypes.jsonDecode,
    epoch: 4,
    payload: <String, Object?>{'encoded': '{"ok":true}'},
  );
  const result = WorkerResult<String>(
    id: 'job-1',
    epoch: 4,
    status: WorkerStatuses.ok,
    payload: 'done',
    errorCode: null,
  );

  _expect(job.id, 'job-1', 'worker job id');
  _expect(job.type, WorkerJobTypes.jsonDecode, 'worker job type');
  _expect(job.epoch, 4, 'worker job epoch');
  _expect(
    job.payload['encoded'],
    '{"ok":true}',
    'worker job payload',
  );
  _expect(result.id, 'job-1', 'worker result id');
  _expect(result.epoch, 4, 'worker result epoch');
  _expect(result.status, WorkerStatuses.ok, 'worker result status');
  _expect(result.payload, 'done', 'worker result payload');
  _expect(result.errorCode, null, 'worker result error code');
}

Future<void> _persistentWorkerExecutesCpuOperations() async {
  final worker = await PersistentCpuWorker.start(initialEpoch: 3);
  _expect(worker.isClosed, false, 'worker starts open');
  _expect(worker.spawnCount, 1, 'one isolate is spawned for one worker');

  final decoded = await worker.submit<Object?>(
    const WorkerJob<Map<String, Object?>>(
      id: 'decode',
      type: WorkerJobTypes.jsonDecode,
      epoch: 3,
      payload: <String, Object?>{
        'encoded': '{"items":[1,2,3],"label":"ok"}',
      },
    ),
  );
  _expect(decoded.status, WorkerStatuses.ok, 'json decode succeeds');
  final decodedMap = decoded.payload as Map;
  _expect(decodedMap['label'], 'ok', 'json decode returns payload');

  const scope = 'ar->de|pack';
  const body = '{"value":"Fahrkarte"}';
  const validator = 'phase13b.test.v1';
  final checksum = await worker.submit<String>(
    const WorkerJob<Map<String, Object?>>(
      id: 'checksum128',
      type: WorkerJobTypes.checksum128,
      epoch: 3,
      payload: <String, Object?>{
        'scopeKey': scope,
        'content': body,
        'validatorVersion': validator,
      },
    ),
  );
  _expect(
    checksum.payload,
    ContentChecksum.compute(
      scopeKey: scope,
      content: body,
      validatorVersion: validator,
    ),
    'worker checksum128 matches canonical checksum',
  );

  final sha = await worker.submit<String>(
    const WorkerJob<Map<String, Object?>>(
      id: 'sha256',
      type: WorkerJobTypes.sha256,
      epoch: 3,
      payload: <String, Object?>{'content': 'abc'},
    ),
  );
  _expect(
    sha.payload,
    'ba7816bf8f01cfea414140de5dae2223'
    'b00361a396177a9cb410ff61f20015ad',
    'worker sha256 is correct',
  );

  final ranked = await worker.submit<Object?>(
    const WorkerJob<Map<String, Object?>>(
      id: 'fuzzy',
      type: WorkerJobTypes.fuzzyRank,
      epoch: 3,
      payload: <String, Object?>{
        'query': 'fahrkarte',
        'candidates': <Map<String, Object?>>[
          <String, Object?>{'id': 'a', 'text': 'Fahrkarte'},
          <String, Object?>{'id': 'b', 'text': 'Fahrplan'},
          <String, Object?>{'id': 'c', 'text': 'Apfel'},
        ],
        'limit': 3,
      },
    ),
  );
  final rows = ranked.payload as List;
  _expect((rows.first as Map)['id'], 'a', 'fuzzy ranking best match');
  _expect(worker.spawnCount, 1, 'worker isolate remains persistent');

  await worker.close();
}

Future<void> _pairSwitchDropsQueuedJobs() async {
  final worker = await PersistentCpuWorker.start(initialEpoch: 9);

  final expensiveCandidates = <Map<String, Object?>>[
    for (var i = 0; i < 1200; i += 1)
      <String, Object?>{
        'id': 'candidate-$i',
        'text':
            'candidate phrase $i with enough material for edit distance work',
      },
  ];

  final running = worker.submit<Object?>(
    WorkerJob<Map<String, Object?>>(
      id: 'running-old',
      type: WorkerJobTypes.fuzzyRank,
      epoch: 9,
      payload: <String, Object?>{
        'query': 'candidate phrase 1199',
        'candidates': expensiveCandidates,
        'limit': 20,
      },
    ),
  );
  final queuedA = worker.submit<Object?>(
    const WorkerJob<Map<String, Object?>>(
      id: 'queued-a',
      type: WorkerJobTypes.jsonDecode,
      epoch: 9,
      payload: <String, Object?>{'encoded': '{"a":1}'},
    ),
  );
  final queuedB = worker.submit<Object?>(
    const WorkerJob<Map<String, Object?>>(
      id: 'queued-b',
      type: WorkerJobTypes.jsonDecode,
      epoch: 9,
      payload: <String, Object?>{'encoded': '{"b":2}'},
    ),
  );

  _expect(worker.pendingCount >= 2, true, 'old jobs queue before switch');
  worker.advanceEpoch(10);
  _expect(worker.pendingCount, 0, 'pair switch clears queued old jobs');

  final resultA = await queuedA;
  final resultB = await queuedB;
  _expect(resultA.status, WorkerStatuses.stale, 'queued A is stale');
  _expect(resultB.status, WorkerStatuses.stale, 'queued B is stale');
  _expect(resultA.epoch, 9, 'stale result preserves original epoch');
  _expect(resultB.epoch, 9, 'stale result preserves original epoch');

  final runningResult = await running;
  _expect(
    runningResult.epoch,
    9,
    'in-flight job preserves its submission epoch',
  );
  _expect(
    runningResult.status,
    WorkerStatuses.stale,
    'in-flight old result is stale after the pair switch',
  );

  final fresh = await worker.submit<Object?>(
    const WorkerJob<Map<String, Object?>>(
      id: 'fresh',
      type: WorkerJobTypes.jsonDecode,
      epoch: 10,
      payload: <String, Object?>{'encoded': '{"fresh":true}'},
    ),
  );
  _expect(fresh.status, WorkerStatuses.ok, 'new epoch work is accepted');

  await worker.close();
}

Future<void> _unsendablePayloadDoesNotStallQueue() async {
  final worker = await PersistentCpuWorker.start(initialEpoch: 2);
  final unsendable = ReceivePort('phase13b.unsendable');

  final failed = await worker.submit<Object?>(
    WorkerJob<Map<String, Object?>>(
      id: 'unsendable',
      type: WorkerJobTypes.jsonDecode,
      epoch: 2,
      payload: <String, Object?>{'encoded': unsendable},
    ),
  );
  _expect(
    failed.status,
    WorkerStatuses.error,
    'unsendable payload becomes a contained worker error',
  );
  _expect(
    failed.errorCode,
    'invalid_payload',
    'unsendable payload reports a stable error code',
  );

  final fresh = await worker.submit<Object?>(
    const WorkerJob<Map<String, Object?>>(
      id: 'after-unsendable',
      type: WorkerJobTypes.jsonDecode,
      epoch: 2,
      payload: <String, Object?>{'encoded': '{"ok":true}'},
    ),
  );
  _expect(
    fresh.status,
    WorkerStatuses.ok,
    'queue continues after an unsendable payload',
  );

  unsendable.close();
  await worker.close();
}

Future<void> _workerClosesSafely() async {
  final worker = await PersistentCpuWorker.start(initialEpoch: 1);
  await worker.close();
  _expect(worker.isClosed, true, 'worker closes');

  var rejected = false;
  try {
    await worker.submit<Object?>(
      const WorkerJob<Map<String, Object?>>(
        id: 'after-close',
        type: WorkerJobTypes.jsonDecode,
        epoch: 1,
        payload: <String, Object?>{'encoded': '{}'},
      ),
    );
  } on StateError {
    rejected = true;
  }
  _expect(rejected, true, 'closed worker rejects new jobs');
}

Future<void> _runtimeOwnsOneWorkerAndRejectsStaleResults() async {
  final source = await File(
    'lib/core/agents/system_agent_runtime.dart',
  ).readAsString();
  final workerSource = await File(
    'lib/core/worker/persistent_cpu_worker.dart',
  ).readAsString();
  final memoryAgentSource = await File(
    'lib/core/agents/sys_memory_agent.dart',
  ).readAsString();
  final memoryModelsSource = await File(
    'lib/core/agents/memory_models.dart',
  ).readAsString();
  final packRepositorySource = await File(
    'lib/core/orchestration/language_pack_repository.dart',
  ).readAsString();

  _expect(
    _count(source, 'PersistentCpuWorker.start('),
    1,
    'runtime starts exactly one persistent CPU worker',
  );
  _expect(
    source.contains('_cpuWorker.advanceEpoch('),
    true,
    'runtime advances worker epoch on pair changes',
  );
  _expect(
    source.contains('result.epoch != pairEpoch'),
    true,
    'runtime rejects stale worker results',
  );
  _expect(
    source.contains('await _cpuWorker.close()'),
    true,
    'runtime closes worker during shutdown',
  );
  _expect(
    workerSource.contains('ReceivePort(') &&
        workerSource.contains('SendPort'),
    true,
    'worker uses isolate message ports',
  );
  _expect(
    workerSource.contains('Timer.periodic'),
    false,
    'worker has no idle polling loop',
  );
  _expect(
    _count(workerSource, 'Isolate.spawn<'),
    1,
    'persistent worker owns one isolate spawn path',
  );
  _expect(
    workerSource.contains('Isolate.run('),
    false,
    'worker never spawns per-job isolates',
  );
  _expect(
    memoryAgentSource.contains('jsonDecode(') ||
        memoryModelsSource.contains('jsonDecode('),
    false,
    'memory runtime JSON decoding is offloaded',
  );
  _expect(
    packRepositorySource.contains('WorkerJobTypes.jsonDecode') &&
        packRepositorySource.contains('WorkerJobTypes.checksum128'),
    true,
    'runtime pack repository offloads decode and checksum',
  );
  _expect(
    packRepositorySource.contains('jsonEncode('),
    false,
    'runtime pack repository does not encode checksum payload on main isolate',
  );
  _expect(
    source.contains('cpuWorker: _cpuWorker'),
    true,
    'runtime injects its single worker into pack loading',
  );
}

int _count(String source, String needle) =>
    source.split(needle).length - 1;

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Phase 13B contract failed: $contract. '
      'Expected <$expected>, got <$actual>.',
    );
  }
}
