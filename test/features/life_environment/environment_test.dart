import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_environment/environment_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_environment/environment_models.dart';
import 'package:deutsch_bilarabi/features/life_environment/environment_screen.dart';
import 'package:deutsch_bilarabi/features/life_environment/gardening_balcony_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_environment/weather_alerts_sub_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnvironmentMasterOrchestrator', () {
    test('defaults to severe weather and performs bilingual local search', () {
      final orchestrator = EnvironmentMasterOrchestrator();

      expect(orchestrator.category, EnvironmentCategory.severeWeather);
      expect(
        orchestrator.visibleEntries.any((entry) => entry.id == 'weather-dwd'),
        isTrue,
      );

      orchestrator.setQuery('Glätte');

      expect(orchestrator.visibleEntries, hasLength(1));
      expect(orchestrator.visibleEntries.single.id, 'weather-ice');
    });

    test('switches to gardening and manages urgent weather alert state', () {
      final orchestrator = EnvironmentMasterOrchestrator();

      orchestrator
        ..setCategory(EnvironmentCategory.gardeningBalcony)
        ..setQuery('Hecke')
        ..selectUrgentAlert(UrgentWeatherKind.unwetter);

      expect(orchestrator.category, EnvironmentCategory.gardeningBalcony);
      expect(orchestrator.visibleEntries, hasLength(1));
      expect(orchestrator.visibleEntries.single.id, 'garden-hedge-period');
      expect(orchestrator.activeUrgentAlert?.kind, UrgentWeatherKind.unwetter);

      orchestrator.clearUrgentAlert();
      expect(orchestrator.activeUrgentAlert, isNull);
    });
  });

  test('sub-agents cover DWD alerts, weather hazards, and garden rules', () {
    const weather = WeatherAlertsSubAgent();
    const gardening = GardeningBalconySubAgent();

    expect(
      weather.entries.map((entry) => entry.id),
      containsAll(<String>[
        'weather-dwd',
        'weather-storm',
        'weather-ice',
        'weather-heat',
      ]),
    );
    expect(
      gardening.entries.map((entry) => entry.id),
      containsAll(<String>[
        'garden-balcony-planting',
        'garden-kleingarten-rules',
        'garden-lawn-hours',
        'garden-hedge-period',
      ]),
    );
  });

  testWidgets(
    'hub uses glass cards, safe scrolling, BiDi text, filters, and alert bar',
    (tester) async {
      final orchestrator = EnvironmentMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: EnvironmentMasterHub(orchestrator: orchestrator),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);

      final directions = tester
          .widgetList<Directionality>(find.byType(Directionality))
          .map((widget) => widget.textDirection)
          .toSet();
      expect(directions, contains(TextDirection.ltr));
      expect(directions, contains(TextDirection.rtl));

      await tester.tap(
        find.byKey(const ValueKey<String>('environment-alert-unwetter')),
      );
      await tester.pump();
      expect(orchestrator.activeUrgentAlert?.kind, UrgentWeatherKind.unwetter);
      expect(find.textContaining('Unwetterwarnung'), findsWidgets);

      await tester.tap(
        find.byKey(
          const ValueKey<String>('environment-category-gardeningBalcony'),
        ),
      );
      await tester.pump();

      expect(orchestrator.category, EnvironmentCategory.gardeningBalcony);
      expect(find.textContaining('Kleingartenverein'), findsWidgets);
      expect(find.textContaining('1. März'), findsWidgets);
    },
  );
}
