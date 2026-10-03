import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_rent_housing/rent_housing_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_rent_housing/rent_housing_models.dart';
import 'package:deutsch_bilarabi/features/life_rent_housing/rent_housing_module.dart';
import 'package:deutsch_bilarabi/features/life_rent_housing/rent_housing_screen.dart';
import 'package:deutsch_bilarabi/services/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RentHousingMasterOrchestrator', () {
    test('starts with contract and costs and searches bilingual core content', () {
      final orchestrator = RentHousingMasterOrchestrator();

      expect(orchestrator.section, RentHousingSection.contractAndCosts);
      expect(
        orchestrator.visibleEntries.any(
          (entry) => entry.id == 'rent-core-mietvertrag',
        ),
        isTrue,
      );

      orchestrator.setQuery('Nebenkosten');

      expect(orchestrator.visibleEntries, hasLength(1));
      expect(
        orchestrator.visibleEntries.single.id,
        'rent-core-nebenkosten',
      );
    });

    test('switches to handover and exposes protocol data model', () {
      final orchestrator = RentHousingMasterOrchestrator();

      orchestrator.setSection(RentHousingSection.handoverAndDefects);

      expect(orchestrator.section, RentHousingSection.handoverAndDefects);
      expect(
        orchestrator.visibleEntries.any(
          (entry) => entry.id == 'rent-core-uebergabeprotokoll',
        ),
        isTrue,
      );

      const protocol = HandoverProtocolRecord(
        addressLabel: 'Musterstraße 10',
        meterReadings: <MeterReading>[
          MeterReading(labelDe: 'Strom', value: '12345 kWh'),
        ],
        keysCount: 3,
        notes: 'Wohnzimmer ohne sichtbare Schäden',
      );

      expect(protocol.keysCount, 3);
      expect(protocol.meterReadings.single.labelDe, 'Strom');
    });

    test('rent contract and ancillary-cost models preserve explicit values', () {
      const contract = RentContractRecord(
        kaltmiete: 700,
        nebenkostenAdvance: 180,
        heatingAdvance: 90,
        kaution: 2100,
        currencyCode: 'EUR',
      );

      expect(contract.kaltmiete, 700);
      expect(contract.nebenkostenAdvance, 180);
      expect(contract.heatingAdvance, 90);
      expect(contract.monthlyPlannedOutlay, 970);

      const cost = NebenkostenItem(
        labelDe: 'Wasser',
        labelAr: 'المياه',
        amount: 35,
      );
      expect(cost.amount, 35);
    });
  });

  test('module descriptor and global feature registry expose rent housing', () {
    expect(RentHousingModule.id, 'life_rent_housing');
    expect(RentHousingModule.routeName, '/life/rent-housing');
    expect(
      featureRegistry.any(
        (feature) => feature.name.contains('السكن والإيجار') && feature.active,
      ),
      isTrue,
    );
  });

  testWidgets(
    'master hub uses glass cards, safe scrolling, explicit BiDi, and controls',
    (tester) async {
      final orchestrator = RentHousingMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: RentHousingMasterHub(orchestrator: orchestrator),
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

      final handoverChip = find.byKey(
        const ValueKey<String>(
          'rent-housing-section-handoverAndDefects',
        ),
      );
      await tester.ensureVisible(handoverChip);
      await tester.tap(handoverChip);
      await tester.pump();

      expect(orchestrator.section, RentHousingSection.handoverAndDefects);
      expect(find.textContaining('Übergabeprotokoll'), findsWidgets);
    },
  );
}
