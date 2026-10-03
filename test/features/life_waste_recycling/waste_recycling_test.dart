import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_waste_recycling/bulky_and_depot_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_waste_recycling/household_sorting_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_waste_recycling/waste_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_waste_recycling/waste_models.dart';
import 'package:deutsch_bilarabi/features/life_waste_recycling/waste_recycling_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WasteMasterOrchestrator', () {
    test('defaults to household sorting, searches locally, and switches category', () {
      final orchestrator = WasteMasterOrchestrator();

      expect(orchestrator.category, WasteCategory.householdSortingPfand);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'household-yellow-packaging',
        ),
        isTrue,
      );

      orchestrator.setQuery('Mehrwegpfand');

      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(orchestrator.visiblePhrases.single.id, 'household-pfand-types');

      orchestrator
        ..clearSearch()
        ..setCategory(WasteCategory.bulkyWasteDepot);

      expect(orchestrator.category, WasteCategory.bulkyWasteDepot);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'bulky-pickup-request',
        ),
        isTrue,
      );
    });

    test('quick sorting lookup routes known items and fails safe for unknowns', () {
      final orchestrator = WasteMasterOrchestrator();

      orchestrator.setLookupQuery('Batterie');
      expect(orchestrator.lookupResult.isKnown, isTrue);
      expect(orchestrator.lookupResult.routeDe, contains('Sammelstelle'));
      expect(orchestrator.lookupResult.noteDe, contains('lokalen'));

      orchestrator.setLookupQuery('Zeitung');
      expect(orchestrator.lookupResult.routeDe, contains('Altpapier'));

      orchestrator.setLookupQuery('unbekannter Verbundstoff');
      expect(orchestrator.lookupResult.isKnown, isFalse);
      expect(orchestrator.lookupResult.routeDe, contains('Abfallberatung'));
    });
  });

  test('sub-agents cover sorting, Pfand, glass, Sperrmüll, hazardous waste, and depot', () {
    const household = HouseholdSortingSubAgent();
    const bulky = BulkyAndDepotSubAgent();

    expect(
      household.phrases.map((phrase) => phrase.id),
      containsAll(<String>[
        'household-yellow-packaging',
        'household-bio-bin',
        'household-paper',
        'household-residual',
        'household-pfand-types',
        'household-glass-times',
      ]),
    );
    expect(
      bulky.phrases.map((phrase) => phrase.id),
      containsAll(<String>[
        'bulky-pickup-request',
        'bulky-pickup-rules',
        'depot-hazardous-batteries',
        'depot-visit-rules',
      ]),
    );
  });

  testWidgets(
    'hub uses glass cards, safe scrolling, explicit BiDi, lookup, and live controls',
    (tester) async {
      final orchestrator = WasteMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: WasteRecyclingMasterHub(orchestrator: orchestrator),
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

      final lookup = find.byKey(const ValueKey<String>('waste-lookup'));
      await tester.ensureVisible(lookup);
      await tester.enterText(lookup, 'Batterie');
      await tester.pump();

      expect(orchestrator.lookupQuery, 'Batterie');
      expect(find.textContaining('Sammelstelle'), findsWidgets);

      final bulkyCategory = find.byKey(
        const ValueKey<String>('waste-category-bulkyWasteDepot'),
      );
      await tester.ensureVisible(bulkyCategory);
      await tester.tap(bulkyCategory);
      await tester.pump();

      expect(orchestrator.category, WasteCategory.bulkyWasteDepot);
      expect(find.textContaining('Sperrmüll'), findsWidgets);
    },
  );
}
