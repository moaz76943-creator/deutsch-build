import 'package:flutter/material.dart';

import 'clothing_dependencies.dart';
import 'clothing_master_orchestrator.dart';
import 'clothing_master_screen.dart';

final class ClothingAlterationsModule {
  final ClothingAlterationsDependencies dependencies;

  const ClothingAlterationsModule({
    this.dependencies = const ClothingAlterationsDependencies(),
  });

  ClothingMasterOrchestrator get orchestrator =>
      ClothingMasterOrchestrator(dependencies: dependencies);

  Widget buildScreen() =>
      ClothingAlterationsMasterScreen(orchestrator: orchestrator);

  Route<void> buildRoute() =>
      MaterialPageRoute<void>(builder: (_) => buildScreen());
}
