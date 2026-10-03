import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/pharmacy_master_hub.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/pharmacy_models.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/pharmacy_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('models keep prescription kinds, dosage, and dosage forms explicit', () {
    expect(
      PrescriptionKind.values,
      containsAll(<PrescriptionKind>[
        PrescriptionKind.ePrescription,
        PrescriptionKind.privatePrescription,
        PrescriptionKind.greenRecommendation,
      ]),
    );
    expect(MedicationForm.values, contains(MedicationForm.tablet));
    expect(MedicationForm.values, contains(MedicationForm.drops));

    const dose = DoseInstruction(
      amountText: 'eine Tablette',
      frequencyText: 'zweimal täglich',
      timingText: 'nach dem Essen',
    );
    expect(dose.summaryDe, contains('zweimal täglich'));
    expect(dose.summaryDe, contains('nach dem Essen'));
  });

  test('orchestrator switches sections and searches German or Arabic', () {
    final orchestrator = PharmacyMasterOrchestrator();

    expect(orchestrator.section, PharmacyHubSection.prescriptions);

    orchestrator.setQuery('E-Rezept');
    expect(orchestrator.visibleCards, hasLength(1));
    expect(orchestrator.visibleCards.single.id, 'hub-prescriptions');

    orchestrator
      ..setSection(PharmacyHubSection.otcConsultation)
      ..setQuery('استشارة');
    expect(orchestrator.visibleCards, hasLength(1));
    expect(orchestrator.visibleCards.single.id, 'hub-otc');
  });

  test('module factory exposes a stable named route for DI/routing', () {
    const factory = DefaultPharmacyMedicationModuleFactory();
    final route = factory.createRoute();

    expect(route.settings.name, PharmacyMedicationModule.routeName);
  });

  testWidgets('hub uses glass cards, safe scrolling, and explicit BiDi', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PharmacyMasterHub()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Apotheke & Medikamente'), findsOneWidget);

    final directions = tester
        .widgetList<Directionality>(find.byType(Directionality))
        .map((widget) => widget.textDirection)
        .toSet();
    expect(directions, contains(TextDirection.ltr));
    expect(directions, contains(TextDirection.rtl));
  });
}
