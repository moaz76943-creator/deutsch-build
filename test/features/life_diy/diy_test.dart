import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_diy/diy_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_diy/diy_models.dart';
import 'package:deutsch_bilarabi/features/life_diy/diy_screen.dart';
import 'package:deutsch_bilarabi/features/life_diy/hardware_store_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_diy/tool_rental_sub_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiyMasterOrchestrator', () {
    test('defaults to hardware, filters locally, and switches domains', () {
      final orchestrator = DiyMasterOrchestrator();

      expect(orchestrator.domain, DiyDomain.materialsHardware);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'hardware-screws-dowels',
        ),
        isTrue,
      );

      orchestrator.setQuery('Holzzuschnitt');

      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(orchestrator.visiblePhrases.single.id, 'hardware-wood-cut');

      orchestrator
        ..clearSearch()
        ..setDomain(DiyDomain.servicesRental);

      expect(orchestrator.domain, DiyDomain.servicesRental);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'rental-deposit',
        ),
        isTrue,
      );
    });

    test('unit converter handles mm, cm, and m without hidden pivots', () {
      final orchestrator = DiyMasterOrchestrator();

      expect(orchestrator.convertedValue, 1);
      expect(orchestrator.formattedConversion, '1 m');

      orchestrator
        ..setConversionValue(2500)
        ..setToUnit(DiyLengthUnit.centimeter);

      expect(orchestrator.convertedValue, 250);
      expect(orchestrator.formattedConversion, '250 cm');

      orchestrator
        ..setFromUnit(DiyLengthUnit.meter)
        ..setToUnit(DiyLengthUnit.millimeter)
        ..setConversionValue(1.25);

      expect(orchestrator.convertedValue, 1250);
      expect(orchestrator.formattedConversion, '1250 mm');
    });

    test('sizing prompt keeps diameter explicit and defers to manufacturer', () {
      final orchestrator = DiyMasterOrchestrator()..setScrewDiameterMm(6);

      expect(orchestrator.sizingPrompt.german, contains('6 mm'));
      expect(orchestrator.sizingPrompt.german, contains('Herstellerangabe'));
      expect(orchestrator.sizingPrompt.arabic, contains('6 مم'));
    });
  });

  test('sub-agents cover hardware, cutting, rental, deposit, and returns', () {
    const hardware = HardwareStoreSubAgent();
    const rental = ToolRentalSubAgent();

    expect(
      hardware.phrases.map((phrase) => phrase.id),
      containsAll(<String>[
        'hardware-screws-dowels',
        'hardware-paint-type',
        'hardware-wood-cut',
      ]),
    );
    expect(
      rental.phrases.map((phrase) => phrase.id),
      containsAll(<String>[
        'rental-drill-hammer',
        'rental-carpet-cleaner',
        'rental-deposit',
        'rental-return-conditions',
      ]),
    );
  });

  testWidgets(
    'hub uses glass cards, safe scrolling, explicit BiDi, and live controls',
    (tester) async {
      final orchestrator = DiyMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: DiyMasterHub(orchestrator: orchestrator),
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

      expect(find.text('1000 mm = 1 m'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('diy-domain-servicesRental')),
      );
      await tester.pump();

      expect(orchestrator.domain, DiyDomain.servicesRental);
      expect(find.textContaining('Bohrhammer'), findsWidgets);

      final sizeSix = find.byKey(const ValueKey<String>('diy-size-6'));
      await tester.ensureVisible(sizeSix);
      await tester.tap(sizeSix);
      await tester.pump();

      expect(orchestrator.screwDiameterMm, 6);
      expect(find.textContaining('6 mm Durchmesser'), findsOneWidget);
    },
  );
}
