import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/prescriptions/prescription_dispensing_controller.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/prescriptions/prescription_dispensing_screen.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/prescriptions/prescription_dispensing_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/prescriptions/prescription_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prescription channels distinguish E-Rezept, private, and green', () {
    expect(
      PrescriptionChannel.values,
      containsAll(<PrescriptionChannel>[
        PrescriptionChannel.ePrescription,
        PrescriptionChannel.privatePrescription,
        PrescriptionChannel.greenRecommendation,
      ]),
    );
    expect(
      PrescriptionChannel.greenRecommendation.labelDe,
      contains('Grünes Rezept'),
    );
    expect(
      PrescriptionChannel.privatePrescription.labelDe,
      contains('Privatrezept'),
    );
  });

  test('sub-agent covers dispensing, copayment, exemption, and alternatives', () {
    const agent = PrescriptionDispensingSubAgent();
    final corpus = agent.phrases
        .expand((p) => <String>[p.german, p.contextDe, ...p.keywords])
        .join(' ');

    expect(corpus, contains('E-Rezept'));
    expect(corpus, contains('Zuzahlung'));
    expect(corpus, contains('Befreiung'));
    expect(corpus, contains('Aut-idem'));
    expect(corpus, contains('Generikum'));
    expect(corpus, contains('Wirkstoff'));
  });

  test('controller filters locally and supports Arabic search', () {
    final controller = PrescriptionDispensingController();

    controller.setQuery('إعفاء');
    expect(controller.visiblePhrases, hasLength(1));
    expect(controller.visiblePhrases.single.id, 'prescription-exemption');

    controller
      ..clearSearch()
      ..setChannel(PrescriptionChannel.privatePrescription);
    expect(
      controller.visiblePhrases.any(
        (phrase) => phrase.id == 'prescription-private',
      ),
      isTrue,
    );
  });

  testWidgets('screen uses safe glass layout and explicit BiDi', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrescriptionDispensingScreen()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.textContaining('Rezept'), findsWidgets);

    final directions = tester
        .widgetList<Directionality>(find.byType(Directionality))
        .map((widget) => widget.textDirection)
        .toSet();
    expect(directions, contains(TextDirection.ltr));
    expect(directions, contains(TextDirection.rtl));
  });
}
