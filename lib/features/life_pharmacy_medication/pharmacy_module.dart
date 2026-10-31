import 'package:flutter/material.dart';

import 'pharmacy_master_hub.dart';

abstract interface class PharmacyMedicationModuleFactory {
  Route<void> createRoute();
}

final class DefaultPharmacyMedicationModuleFactory
    implements PharmacyMedicationModuleFactory {
  const DefaultPharmacyMedicationModuleFactory();

  @override
  Route<void> createRoute() => PharmacyMedicationModule.route();
}

abstract final class PharmacyMedicationModule {
  static const String routeName = '/life/pharmacy-medication';

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const PharmacyMasterHub(),
      );
}
