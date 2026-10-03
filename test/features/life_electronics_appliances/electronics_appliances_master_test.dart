import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_electronics_appliances/electronics_appliances_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_electronics_appliances/electronics_appliances_models.dart';
import 'package:deutsch_bilarabi/features/life_electronics_appliances/electronics_appliances_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ElectronicsAppliancesMasterOrchestrator', () {
    test('shows specifications-warranty and service-repair routes', () {
      final orchestrator = ElectronicsAppliancesMasterOrchestrator();

      expect(
        orchestrator.visibleRoutes.map((item) => item.id).toSet(),
        containsAll(<ElectronicsRouteId>[
          ElectronicsRouteId.specificationsWarranty,
          ElectronicsRouteId.serviceRepair,
        ]),
      );
    });

    test('filters routes by domain and bilingual search', () {
      final orchestrator = ElectronicsAppliancesMasterOrchestrator();

      orchestrator.setDomain(ElectronicsDomain.serviceRepair);
      expect(
        orchestrator.visibleRoutes.every(
          (item) => item.domain == ElectronicsDomain.serviceRepair,
        ),
        isTrue,
      );

      orchestrator.setDomain(ElectronicsDomain.all);
      orchestrator.setQuery('كفالة');
      expect(
        orchestrator.visibleRoutes.any(
          (item) => item.id == ElectronicsRouteId.specificationsWarranty,
        ),
        isTrue,
      );
    });
  });

  testWidgets('electronics master hub renders safe glass layout',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ElectronicsAppliancesMasterHub()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Elektronik & Haushaltsgeräte'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('electronics-master-search')),
      findsOneWidget,
    );
  });
}
