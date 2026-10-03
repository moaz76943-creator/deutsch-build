import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_car_service/car_service_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_car_service/car_service_models.dart';
import 'package:deutsch_bilarabi/features/life_car_service/car_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarServiceMasterOrchestrator', () {
    test('shows workshop and inspection content by default', () {
      final orchestrator = CarServiceMasterOrchestrator();

      final modes = orchestrator.visiblePhrases.map((item) => item.mode).toSet();

      expect(modes, contains(CarServiceMode.workshop));
      expect(modes, contains(CarServiceMode.inspection));
    });

    test('mode switching isolates workshop content', () {
      final orchestrator = CarServiceMasterOrchestrator();

      orchestrator.setMode(CarServiceMode.workshop);

      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) => item.mode == CarServiceMode.workshop,
        ),
        isTrue,
      );
    });

    test('search matches German and Arabic maintenance terms', () {
      final orchestrator = CarServiceMasterOrchestrator();

      orchestrator.setQuery('Kostenvoranschlag');
      expect(
        orchestrator.visiblePhrases.any(
          (item) => item.topic == CarServiceTopic.costEstimate,
        ),
        isTrue,
      );

      orchestrator.setQuery('فحص');
      expect(
        orchestrator.visiblePhrases.any(
          (item) => item.mode == CarServiceMode.inspection,
        ),
        isTrue,
      );
    });

    test('seasonal tire bar is guidance rather than a fixed legal date', () {
      final orchestrator = CarServiceMasterOrchestrator();

      expect(orchestrator.seasonalTireGerman, contains('O bis O'));
      expect(orchestrator.seasonalTireGerman, contains('Faustregel'));
      expect(orchestrator.seasonalTireGerman, contains('situativ'));
      expect(orchestrator.seasonalTireGerman, contains('Alpine-Symbol'));
    });

    test('inspection content distinguishes minor and major defects', () {
      final orchestrator = CarServiceMasterOrchestrator()
        ..setMode(CarServiceMode.inspection);

      final text = orchestrator.visiblePhrases
          .map((item) => item.titleDe + ' ' + item.german)
          .join(' ');

      expect(text, contains('Geringe Mängel'));
      expect(text, contains('Erhebliche Mängel'));
    });
  });

  testWidgets(
      'car service hub uses glass shell, safe scrolling, mode filters and tire bar',
      (tester) async {
    final orchestrator = CarServiceMasterOrchestrator();

    await tester.pumpWidget(
      MaterialApp(
        home: CarServiceMasterHub(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Werkstatt & HU'), findsOneWidget);
    expect(find.byKey(const ValueKey('car-service-search')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('car-service-seasonal-tire-bar')),
      findsOneWidget,
    );

    final inspectionFilter =
        find.byKey(const ValueKey('car-service-mode-inspection'));
    await tester.ensureVisible(inspectionFilter);
    await tester.tap(inspectionFilter);
    await tester.pump();

    expect(orchestrator.mode, CarServiceMode.inspection);
    expect(
      orchestrator.visiblePhrases.every(
        (item) => item.mode == CarServiceMode.inspection,
      ),
      isTrue,
    );
  });
}
