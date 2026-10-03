import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/consultation/otc_consultation_controller.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/consultation/otc_consultation_screen.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/consultation/otc_consultation_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_pharmacy_medication/consultation/otc_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sub-agent covers mild OTC requests and safe pharmacist questions', () {
    const agent = OtcConsultationSubAgent();
    final corpus = agent.phrases
        .expand((p) => <String>[p.german, p.contextDe, ...p.keywords])
        .join(' ');

    expect(corpus, contains('rezeptfrei'));
    expect(corpus, contains('Schmerzen'));
    expect(corpus, contains('Erkältung'));
    expect(corpus, contains('Dosierung'));
    expect(corpus, contains('vor dem Essen'));
    expect(corpus, contains('nach dem Essen'));
  });

  test('leaflet, side effects, and expiry remain separate learning topics', () {
    expect(
      OtcTopic.values,
      containsAll(<OtcTopic>[
        OtcTopic.leaflet,
        OtcTopic.sideEffects,
        OtcTopic.expiryAndStorage,
      ]),
    );

    const agent = OtcConsultationSubAgent();
    final corpus = agent.phrases.map((p) => p.german).join(' ');
    expect(corpus, contains('Packungsbeilage'));
    expect(corpus, contains('Nebenwirkungen'));
    expect(corpus, contains('Verfallsdatum'));
  });

  test('controller searches bilingual content and switches topics', () {
    final controller = OtcConsultationController();

    controller.setQuery('الجرعة');
    expect(controller.visiblePhrases, isNotEmpty);

    controller
      ..clearSearch()
      ..setTopic(OtcTopic.expiryAndStorage);
    expect(
      controller.visiblePhrases.any(
        (phrase) => phrase.id == 'otc-expiry-storage',
      ),
      isTrue,
    );
  });

  testWidgets('screen uses safe glass layout and explicit BiDi', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: OtcConsultationScreen()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.textContaining('Beratung'), findsWidgets);

    final directions = tester
        .widgetList<Directionality>(find.byType(Directionality))
        .map((widget) => widget.textDirection)
        .toSet();
    expect(directions, contains(TextDirection.ltr));
    expect(directions, contains(TextDirection.rtl));
  });
}
