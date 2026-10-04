import '../../../lib/core/agents/memory_models.dart';
import '../../../lib/core/orchestration/agent_batch_processing.dart';
import '../../../lib/core/storage/offline_progress_service.dart';
import '../../../lib/core/storage/runtime_local_state_container.dart';
import '../../../lib/core/storage/validation_hash_cache.dart';

Future<void> main() async {
  await _containerMigratesLegacyMemoryWithoutLoss();
  await _progressPersistsAndStreams();
  await _progressHydratesLegacyMemoryOnce();
  await _validationCacheSkipsRepeatedWork();
  await _batchQueueRemainsCompatible();
}

Future<void> _containerMigratesLegacyMemoryWithoutLoss() async {
  final legacy = MemoryAgentSnapshot.empty()
      .recordProgress(
        rawTaskId: 'task-01',
        score: 0.75,
        completed: false,
        attempts: 1,
        occurredAtEpochMs: 10,
      )
      .encode();
  final physical = _MemoryStore(legacy);

  final container = await RuntimeLocalStateContainer.open(physical);
  final memory = container.namespace('memory');
  _expect(await memory.read(), legacy, 'legacy memory is migrated intact');

  await container.namespace('progress').write('{"probe":true}');
  _expect(
    await memory.read(),
    legacy,
    'writing another namespace does not overwrite memory',
  );

  final reopened = await RuntimeLocalStateContainer.open(physical);
  _expect(
    await reopened.namespace('progress').read(),
    '{"probe":true}',
    'namespaced data survives reopen',
  );
}

Future<void> _progressPersistsAndStreams() async {
  final physical = _MemoryStore();
  final container = await RuntimeLocalStateContainer.open(physical);
  final progress = await OfflineProgressService.open(
    container.namespace('progress'),
  );

  var emissions = 0;
  final sub = progress.changes.listen((_) => emissions += 1);

  await progress.setActivePair(
    sourceLanguageTag: 'ar',
    targetLanguageTag: 'de-DE',
  );
  await progress.recordTaskProgress(
    taskId: 'task-01',
    pointsDelta: 20,
    score: 0.92,
    completed: true,
  );
  await Future<void>.delayed(Duration.zero);

  _expect(progress.snapshot.activePair, 'ar->de-DE', 'active pair is stored');
  _expect(progress.snapshot.totalPoints, 20, 'points are accumulated');
  _expect(
    progress.snapshot.tasks['task-01']?.mastery,
    TaskMasteryStatus.mastered,
    'high-score completed task becomes mastered',
  );
  _expect(emissions >= 2, true, 'progress emits non-blocking stream updates');

  await sub.cancel();
  await progress.close();

  final reopened = await RuntimeLocalStateContainer.open(physical);
  final restored = await OfflineProgressService.open(
    reopened.namespace('progress'),
  );
  _expect(restored.snapshot.activePair, 'ar->de-DE', 'pair restores offline');
  _expect(restored.snapshot.totalPoints, 20, 'points restore offline');
  _expect(
    restored.snapshot.tasks['task-01']?.completed,
    true,
    'task completion restores offline',
  );
  await restored.close();
}

Future<void> _progressHydratesLegacyMemoryOnce() async {
  final memory = MemoryAgentSnapshot.empty()
      .recordProgress(
        rawTaskId: 'task-02',
        score: 0.88,
        completed: true,
        attempts: 3,
        occurredAtEpochMs: 50,
      );
  final physical = _MemoryStore(memory.encode());
  final container = await RuntimeLocalStateContainer.open(physical);
  final progress = await OfflineProgressService.open(
    container.namespace('progress'),
  );

  await progress.hydrateFromMemory(memory);
  _expect(
    progress.snapshot.tasks['task-02']?.completed,
    true,
    'legacy task completion migrates into progress namespace',
  );
  _expect(
    progress.snapshot.tasks['task-02']?.mastery,
    TaskMasteryStatus.mastered,
    'legacy completed task migrates as mastered',
  );

  final pointsAfterFirstHydration = progress.snapshot.totalPoints;
  await progress.hydrateFromMemory(memory);
  _expect(
    progress.snapshot.totalPoints,
    pointsAfterFirstHydration,
    'legacy hydration is idempotent',
  );
  await progress.close();
}

Future<void> _validationCacheSkipsRepeatedWork() async {
  final physical = _MemoryStore();
  final container = await RuntimeLocalStateContainer.open(physical);
  final cache = await ValidationHashCache.open(
    container.namespace('validation'),
  );

  var calls = 0;
  Future<bool> validate() async {
    calls += 1;
    return true;
  }

  final deHash = ContentChecksum.compute(
    scopeKey: 'ar->de-DE|vocabulary|travel.ticket',
    content: 'die Fahrkarte',
    validatorVersion: 'v1',
  );
  final frHash = ContentChecksum.compute(
    scopeKey: 'ar->fr-FR|vocabulary|travel.ticket',
    content: 'le billet',
    validatorVersion: 'v1',
  );
  _expect(deHash.length, 32, 'checksum is a stable 128-bit hex token');
  _expect(deHash == frHash, false, 'language pair and content affect checksum');

  final first = await cache.validateOnce(
    scopeKey: 'ar->de-DE|vocabulary|travel.ticket',
    content: 'die Fahrkarte',
    validatorVersion: 'v1',
    validator: validate,
  );
  final second = await cache.validateOnce(
    scopeKey: 'ar->de-DE|vocabulary|travel.ticket',
    content: 'die Fahrkarte',
    validatorVersion: 'v1',
    validator: validate,
  );

  _expect(first.cacheHit, false, 'first validation executes');
  _expect(second.cacheHit, true, 'identical validation hits cache');
  _expect(calls, 1, 'validator runs only once for identical content');

  await cache.validateOnce(
    scopeKey: 'ar->de-DE|vocabulary|travel.ticket',
    content: 'eine Fahrkarte',
    validatorVersion: 'v1',
    validator: validate,
  );
  _expect(calls, 2, 'content hash change invalidates prior cache entry');

  await cache.close();

  final reopened = await RuntimeLocalStateContainer.open(physical);
  final restored = await ValidationHashCache.open(
    reopened.namespace('validation'),
  );
  final restoredHit = await restored.validateOnce(
    scopeKey: 'ar->de-DE|vocabulary|travel.ticket',
    content: 'eine Fahrkarte',
    validatorVersion: 'v1',
    validator: validate,
  );
  _expect(restoredHit.cacheHit, true, 'validation hash persists offline');
  _expect(calls, 2, 'restored cache avoids validator work');
  await restored.close();
}

Future<void> _batchQueueRemainsCompatible() async {
  final processed = <int>[];
  final queue = AgentBatchQueue<int>(
    maxBatchSize: 2,
    maxPending: 8,
    flushDelay: const Duration(milliseconds: 1),
    dedupeKeyOf: (value) => value.toString(),
    processBatch: (items) async {
      processed.addAll(items);
    },
  );

  final futures = <Future<void>>[
    queue.submit(1),
    queue.submit(1),
    queue.submit(2),
    queue.submit(3),
  ];
  await queue.flush();
  await Future.wait(futures);

  _expect(processed.length, 3, 'batch queue processes unique work only');
  _expect(queue.stats.coalesced, 1, 'batch queue still coalesces duplicates');
  await queue.close();
}

final class _MemoryStore implements MemoryAgentStore {
  _MemoryStore([this.value]);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String encoded) async {
    value = encoded;
  }
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Phase 9 contract failed: $contract. '
      'Expected <$expected>, got <$actual>.',
    );
  }
}
