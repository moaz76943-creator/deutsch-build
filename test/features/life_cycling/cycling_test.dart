import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_cycling/bike_repair_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_cycling/cycle_traffic_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_cycling/cycling_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_cycling/cycling_models.dart';
import 'package:deutsch_bilarabi/features/life_cycling/cycling_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CyclingMasterOrchestrator', () {
    test('defaults to traffic and filters search inside the active category', () {
      final orchestrator = CyclingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      expect(orchestrator.category, CyclingCategory.trafficSafety);
      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) => item.category == CyclingCategory.trafficSafety,
        ),
        isTrue,
      );

      orchestrator.setQuery('Radwegbenutzungspflicht');

      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(
        orchestrator.visiblePhrases.single.topic,
        CyclingTopic.radweg,
      );
    });

    test('switching categories clears search and prevents agent leakage', () {
      final orchestrator = CyclingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      orchestrator.setQuery('Handzeichen');
      expect(orchestrator.visiblePhrases, isNotEmpty);

      orchestrator.setCategory(CyclingCategory.workshopRepair);

      expect(orchestrator.query, isEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) => item.category == CyclingCategory.workshopRepair,
        ),
        isTrue,
      );
      expect(
        orchestrator.visiblePhrases.any(
          (item) => item.topic == CyclingTopic.handSignal,
        ),
        isFalse,
      );
    });

    test('traffic agent covers StVO riding rules and StVZO equipment', () {
      const agent = CycleTrafficSubAgent();
      final joined = agent.phrases
          .map((item) => '${item.titleDe} ${item.german} ${item.keywords.join(' ')}')
          .join(' ');

      expect(joined, contains('Radwegbenutzungspflicht'));
      expect(joined, contains('Einbahnstraße'));
      expect(joined, contains('Handzeichen'));

      final checklist = agent.safetyChecklist
          .map((item) => '${item.labelDe} ${item.legalBasis}')
          .join(' ');
      expect(checklist, contains('Klingel'));
      expect(checklist, contains('zwei unabhängige Bremsen'));
      expect(checklist, contains('Scheinwerfer'));
      expect(checklist, contains('Rückstrahler'));
      expect(checklist, contains('StVZO'));
    });

    test('repair agent covers tyre, tube, chain and workshop communication', () {
      const agent = BikeRepairSubAgent();
      final joined = agent.phrases
          .map((item) => '${item.titleDe} ${item.german} ${item.keywords.join(' ')}')
          .join(' ');

      expect(joined, contains('Reifen flicken'));
      expect(joined, contains('Schlauch wechseln'));
      expect(joined, contains('Kette spannen'));
      expect(joined, contains('Fahrradwerkstatt'));
    });

    test('search matches German and Arabic repair vocabulary', () {
      final orchestrator = CyclingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      orchestrator
        ..setCategory(CyclingCategory.workshopRepair)
        ..setQuery('سلسلة');

      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.any(
          (item) => item.topic == CyclingTopic.chain,
        ),
        isTrue,
      );
    });
  });

  testWidgets(
    'screen uses glass cards, SafeArea, scrolling and explicit LTR/RTL',
    (tester) async {
      final orchestrator = CyclingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: CyclingMasterHub(orchestrator: orchestrator),
        ),
      );

      expect(find.byType(AppGlassCard), findsWidgets);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('cycling-search')), findsOneWidget);

      final german = tester.widget<Directionality>(
        find.byKey(const ValueKey<String>('cycling-german-direction')),
      );
      final arabic = tester.widget<Directionality>(
        find.byKey(const ValueKey<String>('cycling-arabic-direction')),
      );

      expect(german.textDirection, TextDirection.ltr);
      expect(arabic.textDirection, TextDirection.rtl);
      expect(find.text('Fahrradverkehr, StVO & Reparatur'), findsOneWidget);
      expect(find.textContaining('Klingel'), findsWidgets);

      await tester.tap(
        find.byKey(
          const ValueKey<String>('cycling-category-workshopRepair'),
        ),
      );
      await tester.pump();

      expect(orchestrator.category, CyclingCategory.workshopRepair);
      expect(find.textContaining('Fahrradwerkstatt'), findsWidgets);
    },
  );
}
