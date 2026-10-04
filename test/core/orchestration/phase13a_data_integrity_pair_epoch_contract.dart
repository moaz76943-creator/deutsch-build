import 'dart:convert';

import '../../../lib/core/agents/memory_models.dart';
import '../../../lib/core/orchestration/orchestration.dart';
import '../../../lib/core/storage/offline_progress_service.dart';

Future<void> main() async {
  await _progressIsScopedByDirectedPair();
  await _legacyProgressMigratesWithoutPointLoss();
  await _uiProjectionCannotRebindOldPairProgress();
  await _eventsCarryPairEpochAndRejectStaleWork();
  await _applicationTransportSharesPairEpoch();
  await _batchedWorkKeepsSubmissionEpoch();
}

Future<void> _progressIsScopedByDirectedPair() async {
  final store = _MemoryStore();
  final progress = await OfflineProgressService.open(store);

  await progress.setActivePair(
    sourceLanguageTag: 'ar',
    targetLanguageTag: 'de',
  );
  await progress.recordTaskProgress(
    taskId: 'task-01',
    pointsDelta: 40,
    score: 0.95,
    completed: true,
  );

  await progress.setActivePair(
    sourceLanguageTag: 'ar',
    targetLanguageTag: 'fr',
  );
  _expect(progress.snapshot.totalPoints, 0, 'new pair starts clean');
  _expect(
    progress.snapshot.tasks.containsKey('task-01'),
    false,
    'completion does not leak into another directed pair',
  );

  await progress.recordTaskProgress(
    taskId: 'task-01',
    pointsDelta: 7,
    score: 0.25,
    completed: false,
  );

  await progress.setActivePair(
    sourceLanguageTag: 'ar',
    targetLanguageTag: 'de',
  );
  _expect(
    progress.snapshot.tasks['task-01']?.points,
    40,
    'original pair retains its points',
  );
  _expect(
    progress.snapshot.tasks['task-01']?.completed,
    true,
    'original pair retains completion',
  );

  await progress.setActivePair(
    sourceLanguageTag: 'ar',
    targetLanguageTag: 'fr',
  );
  _expect(
    progress.snapshot.tasks['task-01']?.points,
    7,
    'second pair keeps an independent task record',
  );
  _expect(
    progress.snapshot.tasks['task-01']?.completed,
    false,
    'second pair completion stays independent',
  );

  _expect(
    progress.snapshot.tasksForPair('ar', 'de')['task-01']?.points,
    40,
    'pair lookup uses source+target+task composite identity',
  );

  await progress.close();

  final reopened = await OfflineProgressService.open(store);
  _expect(
    reopened.snapshot.tasksForPair('ar', 'de')['task-01']?.points,
    40,
    'first pair persists independently',
  );
  _expect(
    reopened.snapshot.tasksForPair('ar', 'fr')['task-01']?.points,
    7,
    'second pair persists independently',
  );
  await reopened.close();
}

Future<void> _legacyProgressMigratesWithoutPointLoss() async {
  final legacy = jsonEncode(<String, Object?>{
    'schemaVersion': 1,
    'sourceLanguageTag': null,
    'targetLanguageTag': null,
    'updatedAtEpochMs': 50,
    'tasks': <Map<String, Object?>>[
      <String, Object?>{
        'taskId': 'task-02',
        'points': 88,
        'bestScore': 0.88,
        'completed': true,
        'mastery': 'mastered',
        'updatedAtEpochMs': 50,
      },
    ],
  });
  final store = _MemoryStore(legacy);

  final progress = await OfflineProgressService.open(store);

  _expect(
    OfflineProgressSnapshot.schemaVersion,
    2,
    'pair-scoped storage advances the progress schema',
  );
  _expect(
    progress.snapshot.activePair,
    'ar->de',
    'unscoped legacy progress receives the canonical default pair',
  );
  _expect(
    progress.snapshot.tasks['task-02']?.points,
    88,
    'legacy points survive migration',
  );
  _expect(
    progress.snapshot.tasks['task-02']?.completed,
    true,
    'legacy completion survives migration',
  );

  final migrated = jsonDecode(store.value ?? '');
  _expect(
    migrated is Map && migrated['schemaVersion'] == 2,
    true,
    'legacy storage is rewritten to the pair-scoped schema',
  );

  await progress.close();
}

Future<void> _uiProjectionCannotRebindOldPairProgress() async {
  final store = _MemoryStore();
  final progress = await OfflineProgressService.open(store);

  await progress.setActivePair(
    sourceLanguageTag: 'ar',
    targetLanguageTag: 'de',
  );
  await progress.recordTaskProgress(
    taskId: 'task-03',
    pointsDelta: 55,
    score: 0.9,
    completed: true,
  );

  final oldPairTasks = progress.snapshot.tasks.values
      .map((task) => task.toJson())
      .toList(growable: false);

  final projected = OfflineProgressSnapshot.decode(
    jsonEncode(<String, Object?>{
      'schemaVersion': OfflineProgressSnapshot.schemaVersion,
      'sourceLanguageTag': 'ar',
      'targetLanguageTag': 'fr',
      'updatedAtEpochMs': 99,
      'tasks': oldPairTasks,
    }),
  );

  _expect(
    projected.tasks.containsKey('task-03'),
    false,
    'old-pair UI projection cannot appear completed in a new pair',
  );
  _expect(
    projected.tasksForPair('ar', 'de')['task-03']?.points,
    55,
    'projection preserves the embedded original pair identity',
  );

  await progress.close();
}

Future<void> _eventsCarryPairEpochAndRejectStaleWork() async {
  final bus = AgentEventBus.isolated();
  final kernel = OrchestrationKernel(
    eventBus: bus,
    services: ServiceContainer(),
  );
  final source = kernel.connect(
    AgentDescriptor(
      id: 'phase13a.source',
      role: AgentRole.system,
      subscriptions: const <String>{AgentTopics.systemError},
    ),
  );
  final sink = kernel.connect(
    AgentDescriptor(
      id: 'phase13a.sink',
      role: AgentRole.memory,
      subscriptions: const <String>{
        AgentTopics.localizationChangeRequested,
        AgentTopics.learningProgress,
      },
      observesTargetedEvents: true,
    ),
  );

  final received = <AgentEvent>[];
  final subscription = sink.allEvents.listen(received.add);

  source.publish(
    topic: AgentTopics.localizationChangeRequested,
    payload: const <String, Object?>{
      'sourceLocale': 'ar',
      'targetLocale': 'de',
    },
    context: AgentContextSnapshot.empty('switch.1'),
  );

  _expect(bus.pairEpoch, 1, 'first pair switch increments epoch');
  _expect(
    received.last.context.pairEpoch,
    1,
    'pair switch event carries the incremented epoch',
  );

  source.publish(
    topic: AgentTopics.learningProgress,
    payload: const <String, Object?>{'taskId': 'task-01'},
    context: AgentContextSnapshot.empty('progress.1'),
  );
  _expect(
    received.last.context.pairEpoch,
    1,
    'ordinary events inherit the current pair epoch',
  );
  _expect(
    received.last.context.generation > 0,
    true,
    'ordinary events carry a positive generation',
  );

  source.publish(
    topic: AgentTopics.localizationChangeRequested,
    payload: const <String, Object?>{
      'sourceLocale': 'ar',
      'targetLocale': 'fr',
    },
    context: AgentContextSnapshot.empty('switch.2'),
  );
  _expect(bus.pairEpoch, 2, 'second pair switch increments epoch again');

  final deliveredBeforeStale = received.length;
  source.publish(
    topic: AgentTopics.learningProgress,
    payload: const <String, Object?>{'taskId': 'task-01'},
    context: AgentContextSnapshot.empty('stale.progress').withTemporal(
      pairEpoch: 1,
      generation: 77,
    ),
  );

  _expect(
    received.length,
    deliveredBeforeStale,
    'stale event is dropped before reaching subscribers',
  );
  _expect(
    bus.droppedStaleCount,
    1,
    'stale rejection is observable for diagnostics',
  );

  await subscription.cancel();
  await kernel.close();
}

Future<void> _applicationTransportSharesPairEpoch() async {
  final sourceBus = AgentEventBus();
  final receiverBus = AgentEventBus();
  final sourceKernel = OrchestrationKernel(
    eventBus: sourceBus,
    services: ServiceContainer(),
  );
  final receiverKernel = OrchestrationKernel(
    eventBus: receiverBus,
    services: ServiceContainer(),
  );
  final source = sourceKernel.connect(
    AgentDescriptor(
      id: 'phase13a.shared-source',
      role: AgentRole.system,
      subscriptions: const <String>{AgentTopics.systemError},
    ),
  );
  final receiver = receiverKernel.connect(
    AgentDescriptor(
      id: 'phase13a.shared-receiver',
      role: AgentRole.localization,
      subscriptions: const <String>{
        AgentTopics.localizationChangeRequested,
        AgentTopics.localizationChanged,
      },
      observesTargetedEvents: true,
    ),
  );

  final received = <AgentEvent>[];
  final subscription = receiver.allEvents.listen(received.add);
  final before = sourceBus.pairEpoch;
  final droppedBefore = sourceBus.droppedStaleCount;

  final request = source.publish(
    topic: AgentTopics.localizationChangeRequested,
    payload: const <String, Object?>{
      'sourceLocale': 'ar',
      'targetLocale': 'sv',
    },
    context: AgentContextSnapshot.empty('shared.switch'),
  );

  _expect(
    receiverBus.pairEpoch,
    before + 1,
    'application buses share one transport epoch',
  );
  _expect(
    received.single.context.pairEpoch,
    request.context.pairEpoch,
    'shared receiver observes the same pair epoch',
  );

  final responder = receiverKernel.connect(
    AgentDescriptor(
      id: 'phase13a.shared-responder',
      role: AgentRole.polyglot,
      subscriptions: const <String>{AgentTopics.systemError},
    ),
  );
  responder.publish(
    topic: AgentTopics.localizationChanged,
    payload: const <String, Object?>{
      'sourceLocale': 'ar',
      'targetLocale': 'sv',
    },
    context: request.context,
  );

  _expect(
    sourceBus.droppedStaleCount,
    droppedBefore,
    'cross-bus response with the current epoch is not rejected',
  );

  await subscription.cancel();
  await receiverKernel.close();
  await sourceKernel.close();
}

Future<void> _batchedWorkKeepsSubmissionEpoch() async {
  final bus = AgentEventBus.isolated();
  final kernel = OrchestrationKernel(
    eventBus: bus,
    services: ServiceContainer(),
  );
  final source = kernel.connect(
    AgentDescriptor(
      id: 'phase13a.batch-source',
      role: AgentRole.system,
      subscriptions: const <String>{AgentTopics.systemError},
    ),
  );
  final sink = kernel.connect(
    AgentDescriptor(
      id: 'phase13a.batch-sink',
      role: AgentRole.memory,
      subscriptions: const <String>{AgentTopics.learningProgress},
      observesTargetedEvents: true,
    ),
  );

  final received = <AgentEvent>[];
  final subscription = sink.allEvents.listen(received.add);

  source.publish(
    topic: AgentTopics.localizationChangeRequested,
    payload: const <String, Object?>{
      'sourceLocale': 'ar',
      'targetLocale': 'de',
    },
    context: AgentContextSnapshot.empty('batch.switch.1'),
  );

  final dispatcher = source.createBatchDispatcher(
    maxBatchSize: 8,
    maxPending: 8,
    flushDelay: const Duration(hours: 1),
  );
  final oldWork = dispatcher.submit(
    AgentBatchEvent(
      dedupeKey: 'old-progress',
      topic: AgentTopics.learningProgress,
      context: AgentContextSnapshot.empty('batch.old'),
      targetRoles: const <AgentRole>{AgentRole.memory},
      payload: const <String, Object?>{'taskId': 'task-01'},
    ),
  );

  source.publish(
    topic: AgentTopics.localizationChangeRequested,
    payload: const <String, Object?>{
      'sourceLocale': 'ar',
      'targetLocale': 'fr',
    },
    context: AgentContextSnapshot.empty('batch.switch.2'),
  );

  await dispatcher.flush();
  await oldWork;

  _expect(
    received.isEmpty,
    true,
    'queued work submitted under an older pair epoch is rejected',
  );

  final freshWork = dispatcher.submit(
    AgentBatchEvent(
      dedupeKey: 'fresh-progress',
      topic: AgentTopics.learningProgress,
      context: AgentContextSnapshot.empty('batch.fresh'),
      targetRoles: const <AgentRole>{AgentRole.memory},
      payload: const <String, Object?>{'taskId': 'task-01'},
    ),
  );
  await dispatcher.flush();
  await freshWork;

  _expect(received.length, 1, 'fresh batch work is delivered');
  _expect(
    received.single.context.pairEpoch,
    2,
    'batch work retains the epoch captured at submission',
  );
  _expect(
    received.single.context.generation > 0,
    true,
    'batch work receives a monotonic generation',
  );

  await dispatcher.close();
  await subscription.cancel();
  await kernel.close();
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
      'Phase 13A contract failed: $contract. '
      'Expected <$expected>, got <$actual>.',
    );
  }
}
