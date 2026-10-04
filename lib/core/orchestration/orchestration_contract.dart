import 'dart:async';

import 'event_bus.dart';
import 'orchestration_kernel.dart';
import 'orchestration_models.dart';
import 'service_container.dart';

Future<void> main() async {
  final bus = AgentEventBus.isolated();
  final services = ServiceContainer();
  final kernel = OrchestrationKernel(
    eventBus: bus,
    services: services,
  );

  final curriculumToken = ServiceToken<String>('curriculum-version');
  services.registerSingleton(curriculumToken, 'phase-2');
  _expect(
    services.resolve(curriculumToken),
    'phase-2',
    'typed DI singleton resolution',
  );

  var directReferenceRejected = false;
  try {
    final forbiddenToken =
        ServiceToken<AgentReferenceBoundary>('direct-agent-reference');
    services.registerSingleton(
      forbiddenToken,
      _FakeAgentReference(),
    );
  } on ArgumentError {
    directReferenceRejected = true;
  }
  _expect(
    directReferenceRejected,
    true,
    'DI must reject direct agent references',
  );

  var eventReferenceRejected = false;
  try {
    AgentContextSnapshot(
      correlationId: 'bad-ref',
      values: <String, Object?>{'agent': _FakeAgentReference()},
    );
  } on ArgumentError {
    eventReferenceRejected = true;
  }
  _expect(
    eventReferenceRejected,
    true,
    'event context must reject object references',
  );

  var factoryCalls = 0;
  final counterToken = ServiceToken<int>('counter');
  services.registerFactory(counterToken, () {
    factoryCalls += 1;
    return factoryCalls;
  });
  _expect(services.resolve(counterToken), 1, 'factory first resolution');
  _expect(services.resolve(counterToken), 2, 'factory creates a new value');

  final taskAgent = kernel.connect(
    AgentDescriptor(
      id: 'task-agent',
      role: AgentRole.task,
      subscriptions: <String>{AgentTopics.taskRequest, AgentTopics.routeSelected},
    ),
  );
  final designAgent = kernel.connect(
    AgentDescriptor(
      id: 'design-agent',
      role: AgentRole.design,
      subscriptions: <String>{AgentTopics.designRequest},
    ),
  );
  final routingAgent = kernel.connect(
    AgentDescriptor(
      id: 'routing-agent',
      role: AgentRole.routing,
      subscriptions: <String>{AgentTopics.routeRequest},
    ),
  );
  final cardsAgent = kernel.connect(
    AgentDescriptor(
      id: 'cards-agent',
      role: AgentRole.cards,
      subscriptions: <String>{AgentTopics.cardsRequest},
    ),
  );

  _expect(kernel.connectedAgentCount, 4, 'four isolated agent endpoints');
  _expect(
    identical(taskAgent, designAgent),
    false,
    'agents never share endpoint objects',
  );

  final routingMessage = Completer<AgentEvent>();
  final routingSub = routingAgent.events(AgentTopics.routeRequest).listen((event) {
    if (!routingMessage.isCompleted) routingMessage.complete(event);
  });

  taskAgent.publish(
    topic: AgentTopics.routeRequest,
    payload: const <String, Object?>{'taskId': 'task-17'},
    context: AgentContextSnapshot(
      correlationId: 'corr-17',
      values: <String, Object?>{'learnerLevel': 'A2'},
    ),
  );

  final routed = await routingMessage.future.timeout(
    const Duration(seconds: 1),
  );
  _expect(routed.sourceAgentId, 'task-agent', 'event source identity');
  _expect(routed.topic, AgentTopics.routeRequest, 'event topic');
  _expect(
    routed.context.correlationId,
    'corr-17',
    'context correlation survives the bridge',
  );
  _expect(routed.payload['taskId'], 'task-17', 'payload survives event bus');

  var designSawRoute = false;
  final designSub = designAgent.events(AgentTopics.routeRequest).listen((_) {
    designSawRoute = true;
  });
  taskAgent.publish(
    topic: AgentTopics.routeRequest,
    payload: const <String, Object?>{'taskId': 'task-18'},
  );
  await Future<void>.delayed(Duration.zero);
  _expect(
    designSawRoute,
    false,
    'unsubscribed agents must not receive unrelated traffic',
  );

  final cardsMessage = Completer<AgentEvent>();
  final cardsSub = cardsAgent.events(AgentTopics.cardsRequest).listen((event) {
    if (!cardsMessage.isCompleted) cardsMessage.complete(event);
  });
  routingAgent.publish(
    topic: AgentTopics.cardsRequest,
    payload: const <String, Object?>{
      'bankId': 'daily-a1',
      'taskId': 'task-18',
    },
    targetRoles: const <AgentRole>{AgentRole.cards},
  );
  final cardEvent = await cardsMessage.future.timeout(
    const Duration(seconds: 1),
  );
  _expect(
    cardEvent.targetRoles.contains(AgentRole.cards),
    true,
    'target-role routing',
  );
  _expect(bus.publishedCount >= 3, true, 'event bus sequence accounting');

  var duplicateRejected = false;
  try {
    kernel.connect(
      AgentDescriptor(
        id: 'task-agent',
        role: AgentRole.task,
        subscriptions: <String>{AgentTopics.taskRequest},
      ),
    );
  } on StateError {
    duplicateRejected = true;
  }
  _expect(duplicateRejected, true, 'duplicate agent ids must be rejected');

  await routingSub.cancel();
  await designSub.cancel();
  await cardsSub.cancel();
  await kernel.close();

  _expect(bus.isClosed, true, 'kernel closes the event bus');
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}

final class _FakeAgentReference implements AgentReferenceBoundary {}
