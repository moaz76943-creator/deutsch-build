import 'package:flutter/widgets.dart';

import 'emergency_health_master_hub.dart';
import 'emergency_health_master_orchestrator.dart';
import 'emergency_health_models.dart';

final class EmergencyHealthDependencies {
  const EmergencyHealthDependencies({
    this.contentSources = const <EmergencyHealthContentSource>[],
  });

  final List<EmergencyHealthContentSource> contentSources;
}

final class EmergencyHealthModule {
  const EmergencyHealthModule({
    this.dependencies = const EmergencyHealthDependencies(),
  });

  static const String routeName = '/life/emergency-health';

  final EmergencyHealthDependencies dependencies;

  EmergencyHealthMasterOrchestrator createOrchestrator() =>
      EmergencyHealthMasterOrchestrator(
        contentSources: dependencies.contentSources,
      );

  WidgetBuilder get routeBuilder => (context) => EmergencyHealthMasterHub(
        orchestrator: createOrchestrator(),
      );
}
