import 'package:deutsch_bilarabi/features/life_doctor_appointment/consultation/consultation_sicknote_agent.dart';
import 'package:deutsch_bilarabi/features/life_doctor_appointment/consultation/consultation_sicknote_screen.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConsultationSickNoteAgent', () {
    const agent = ConsultationSickNoteAgent();

    test('covers symptoms, duration, allergies, AU and referral', () {
      final corpus = agent.allItems
          .map((item) => '${item.german} ${item.arabic}')
          .join(' ');

      expect(corpus, contains('Seit'));
      expect(corpus, contains('allergisch'));
      expect(corpus, contains('Arbeitsunfähigkeitsbescheinigung'));
      expect(corpus, contains('Krankschreibung'));
      expect(corpus, contains('Überweisung'));
      expect(corpus, contains('Facharzt'));
    });

    test('stage filtering and bilingual search stay deterministic', () {
      expect(agent.itemsFor(ConsultationStage.symptoms), isNotEmpty);
      expect(agent.itemsFor(ConsultationStage.sickNote), isNotEmpty);
      expect(agent.search('ألم'), isNotEmpty);
      expect(agent.search('AU'), isNotEmpty);
    });
  });

  testWidgets('consultation screen uses glass shell and explicit BiDi',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ConsultationSickNoteScreen(
          agent: ConsultationSickNoteAgent(),
        ),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Sprechzimmer & AU'), findsOneWidget);
    expect(find.textContaining('keine medizinische Beratung'), findsOneWidget);
  });
}
