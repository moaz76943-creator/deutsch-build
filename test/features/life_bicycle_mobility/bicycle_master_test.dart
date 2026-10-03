import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_bicycle_mobility/bicycle_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_bicycle_mobility/bicycle_models.dart';
import 'package:deutsch_bilarabi/features/life_bicycle_mobility/bicycle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BicycleMasterOrchestrator', () {
    test('shows purchase-maintenance and traffic-rules routes', () {
      final orchestrator = BicycleMasterOrchestrator();

      expect(
        orchestrator.visibleRoutes.map((item) => item.id).toSet(),
        containsAll(<BicycleRouteId>[
          BicycleRouteId.purchaseMaintenance,
          BicycleRouteId.trafficRules,
        ]),
      );
    });

    test('filters routes by domain and bilingual search', () {
      final orchestrator = BicycleMasterOrchestrator();

      orchestrator.setDomain(BicycleDomain.trafficRules);
      expect(
        orchestrator.visibleRoutes.every(
          (item) => item.domain == BicycleDomain.trafficRules,
        ),
        isTrue,
      );

      orchestrator.setDomain(BicycleDomain.all);
      orchestrator.setQuery('صيانة');
      expect(
        orchestrator.visibleRoutes.any(
          (item) => item.id == BicycleRouteId.purchaseMaintenance,
        ),
        isTrue,
      );
    });
  });

  testWidgets('bicycle master hub uses safe glass layout', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BicycleMasterHub()));

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Fahrrad & Mobilität'), findsOneWidget);
    expect(find.byKey(const ValueKey('bicycle-master-search')), findsOneWidget);
  });
}
