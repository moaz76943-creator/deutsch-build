import '../orchestration/orchestration.dart';
import 'agents.dart';

Future<void> main() async {
  final store = _MemoryStore();
  final runtime = await SystemAgentRuntime.start(memoryStore: store);

  final producerBus = AgentEventBus();
  final producerKernel = OrchestrationKernel(
    eventBus: producerBus,
    services: ServiceContainer(),
  );
  final producer = producerKernel.connect(
    AgentDescriptor(
      id: 'contract.task-producer',
      role: AgentRole.task,
      subscriptions: const <String>{AgentTopics.contextUpdated},
    ),
  );

  producer.publish(
    topic: AgentTopics.routeSelected,
    context: AgentContextSnapshot.empty('route-1'),
    targetRoles: const <AgentRole>{AgentRole.task},
    payload: const <String, Object?>{
      'ok': true,
      'featureKey': 'life_maintenance',
      'curriculumTaskId': 'task-16',
    },
  );
  producer.publish(
    topic: AgentTopics.learningProgress,
    context: AgentContextSnapshot.empty('progress-1'),
    payload: const <String, Object?>{
      'taskId': 'task-16',
      'score': 0.82,
      'completed': true,
      'attempts': 2,
    },
  );
  producer.publish(
    topic: AgentTopics.learningMistake,
    context: AgentContextSnapshot.empty('mistake-1'),
    payload: const <String, Object?>{
      'taskId': 'task-16',
      'weaknessKey': 'dative-preposition',
      'weight': 2,
    },
  );
  producer.publish(
    topic: AgentTopics.learningMistake,
    context: AgentContextSnapshot.empty('mistake-2'),
    payload: const <String, Object?>{
      'taskId': 'task-16',
      'weaknessKey': 'dative-preposition',
      'weight': 1,
    },
  );

  await runtime.flushMemory();

  final snapshot = runtime.memorySnapshot;
  _expect(snapshot.tasks['task-16']?.visits, 1, 'route visit is tracked');
  _expect(snapshot.tasks['task-16']?.completed, true, 'completion is tracked');
  _expect(snapshot.tasks['task-16']?.bestScore, 0.82, 'best score is retained');
  _expect(
    snapshot.weaknesses['dative-preposition']?.weight,
    3,
    'weakness weight accumulates',
  );
  _expect(store.lastEncoded.isNotEmpty, true, 'memory snapshot is persisted');
  _expect(
    snapshot.reviewPriorities.first.weaknessKey,
    'dative-preposition',
    'weakness appears in review priority',
  );

  final restored = await SystemAgentRuntime.start(memoryStore: store);
  _expect(
    restored.memorySnapshot.tasks['task-16']?.completed,
    true,
    'memory restores across runtime restart',
  );
  await restored.close();

  final directive = await runtime.reportError(
    context: 'phase3.route',
    errorType: 'StateError',
    message: 'route failed',
    fatal: true,
  );
  _expect(
    directive.mode,
    RecoveryMode.safeShell,
    'fatal errors route to safe shell',
  );
  _expect(
    directive.context,
    'phase3.route',
    'recovery preserves error context',
  );

  final firstNonFatal = await runtime.reportError(
    context: 'phase3.cards',
    errorType: 'FormatException',
    message: 'bad card',
    fatal: false,
  );
  _expect(
    firstNonFatal.mode,
    RecoveryMode.safeSection,
    'first non-fatal error isolates the section',
  );

  final secondNonFatal = await runtime.reportError(
    context: 'phase3.cards',
    errorType: 'FormatException',
    message: 'bad card again',
    fatal: false,
  );
  final thirdNonFatal = await runtime.reportError(
    context: 'phase3.cards',
    errorType: 'FormatException',
    message: 'bad card third',
    fatal: false,
  );
  _expect(
    secondNonFatal.mode,
    RecoveryMode.safeSection,
    'second repeated error remains section-safe',
  );
  _expect(
    thirdNonFatal.mode,
    RecoveryMode.safeShell,
    'third repeated error escalates to safe shell',
  );

  await producerKernel.close();
  await runtime.close();

  _expect(runtime.isClosed, true, 'system runtime closes cleanly');
}

final class _MemoryStore implements MemoryAgentStore {
  String lastEncoded = '';

  @override
  Future<String?> read() async =>
      lastEncoded.isEmpty ? null : lastEncoded;

  @override
  Future<void> write(String encoded) async {
    lastEncoded = encoded;
  }
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}
