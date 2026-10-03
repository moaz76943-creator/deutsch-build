import 'package:flutter/material.dart';

import 'hardware_store_master_hub.dart';
import 'hardware_store_master_orchestrator.dart';
import 'services/cutting_rental_sub_agent.dart';
import 'tools/tools_materials_sub_agent.dart';

final class HardwareStoreModuleDependencies {
  const HardwareStoreModuleDependencies({
    this.toolsMaterials = const ToolsMaterialsSubAgent(),
    this.cuttingRental = const CuttingRentalSubAgent(),
  });

  final ToolsMaterialsSubAgent toolsMaterials;
  final CuttingRentalSubAgent cuttingRental;

  HardwareStoreMasterOrchestrator createOrchestrator() =>
      HardwareStoreMasterOrchestrator(
        toolsMaterials: toolsMaterials,
        cuttingRental: cuttingRental,
      );
}

abstract final class HardwareStoreModule {
  static const String routeName = '/life/hardware-store-diy';

  static Map<String, WidgetBuilder> routes({
    HardwareStoreModuleDependencies dependencies =
        const HardwareStoreModuleDependencies(),
  }) =>
      <String, WidgetBuilder>{
        routeName: (_) => HardwareStoreMasterHub(
              orchestrator: dependencies.createOrchestrator(),
            ),
      };
}
