import 'dart:async';

import 'event_bus.dart';
import 'localization_role_observers.dart';
import 'orchestration_kernel.dart';
import 'orchestration_models.dart';
import 'service_container.dart';

Future<void> main() async {
  final bus = AgentEventBus.isolated();
  final kernel = OrchestrationKernel(
    eventBus: bus,
    services: ServiceContainer(),
  );
  final observers = LocalizationDesignRoutingObservers.connect(kernel);

  final publisher = kernel.connect(
    AgentDescriptor(
      id: 'phase6.localization-publisher',
      role: AgentRole.localization,
      subscriptions: const <String>{AgentTopics.contextUpdated},
    ),
  );

  final designReady = Completer<AgentLocalizationState>();
  final routingReady = Completer<AgentLocalizationState>();

  final designSub = observers.designChanges.listen((state) {
    if (!designReady.isCompleted) designReady.complete(state);
  });
  final routingSub = observers.routingChanges.listen((state) {
    if (!routingReady.isCompleted) routingReady.complete(state);
  });

  publisher.publish(
    topic: AgentTopics.localizationChanged,
    targetRoles: const <AgentRole>{
      AgentRole.design,
      AgentRole.routing,
    },
    payload: const <String, Object?>{
      'revision': 7,
      'userLocale': 'fa',
      'sourceLocale': 'ar',
      'targetLocale': 'de',
      'fallbackLocale': 'en',
      'direction': 'rtl',
      'isRtl': true,
      'loadedLocales': <String>['ar', 'de', 'en'],
    },
  );

  final design = await designReady.future.timeout(
    const Duration(seconds: 1),
  );
  final routing = await routingReady.future.timeout(
    const Duration(seconds: 1),
  );

  _expect(design.revision, 7, 'design observes localization revision');
  _expect(design.direction, 'rtl', 'design observes RTL direction');
  _expect(routing.sourceLocale, 'ar', 'routing observes SOURCE');
  _expect(routing.targetLocale, 'de', 'routing observes TARGET');
  _expect(
    routing.revision,
    design.revision,
    'design and routing share one localization revision',
  );

  await designSub.cancel();
  await routingSub.cancel();
  await observers.close();
  await kernel.close();

  _expect(bus.isClosed, true, 'isolated observer bus closes');
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}
