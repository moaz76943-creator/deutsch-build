import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_gas_station_carwash/gas_station_carwash_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_gas_station_carwash/gas_station_carwash_models.dart';
import 'package:deutsch_bilarabi/features/life_gas_station_carwash/gas_station_carwash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GasStationCarwashMasterOrchestrator', () {
    test('shows fuel-payment and automatic-wash routes', () {
      final orchestrator = GasStationCarwashMasterOrchestrator();

      expect(
        orchestrator.visibleRoutes.map((item) => item.id).toSet(),
        containsAll(<GasStationRouteId>[
          GasStationRouteId.fuelPayment,
          GasStationRouteId.automaticWash,
        ]),
      );
    });

    test('filters by domain and bilingual search', () {
      final orchestrator = GasStationCarwashMasterOrchestrator();

      orchestrator.setDomain(GasStationDomain.automaticWash);
      expect(
        orchestrator.visibleRoutes.every(
          (item) => item.domain == GasStationDomain.automaticWash,
        ),
        isTrue,
      );

      orchestrator.setDomain(GasStationDomain.all);
      orchestrator.setQuery('دفع');
      expect(
        orchestrator.visibleRoutes.any(
          (item) => item.id == GasStationRouteId.fuelPayment,
        ),
        isTrue,
      );
    });
  });

  testWidgets('master hub renders safe glass layout', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GasStationCarwashMasterHub()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Tankstelle & Autowäsche'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('gas-station-master-search')),
      findsOneWidget,
    );
  });
}
