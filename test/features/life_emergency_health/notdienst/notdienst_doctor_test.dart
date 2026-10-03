import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/emergency_health_models.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/notdienst/notdienst_doctor_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/notdienst/notdienst_phrase_bank.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/notdienst/notdienst_screen.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/notdienst/urgent_medical_terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotdienstDoctorSubAgent', () {
    test('covers 116117, pharmacy night service, and safety escalation', () {
      const agent = NotdienstDoctorSubAgent();

      expect(agent.domain, EmergencyHealthDomain.medicalOnCall);
      expect(agent.items, isNotEmpty);

      final corpus = agent.items
          .expand(
            (item) => <String>[
              item.titleDe,
              item.german,
              item.arabic,
              item.explanationAr,
              ...item.tags,
            ],
          )
          .join(' ');

      expect(corpus, contains('116 117'));
      expect(corpus, contains('112'));
      expect(corpus, contains('Apotheken-Notdienst'));
      expect(corpus, contains('Notdienstgebühr'));
      expect(corpus, contains('2,50 Euro'));
      expect(corpus, contains('noctu'));
    });

    test('keeps all routine items non-life-threatening', () {
      const agent = NotdienstDoctorSubAgent();

      expect(
        agent.items.every(
          (item) =>
              item.urgency ==
              EmergencyUrgency.urgentNonLifeThreatening,
        ),
        isTrue,
      );
    });
  });

  group('UrgentMedicalTerms', () {
    test('supports location, severity, quality, onset, and duration of pain', () {
      const terms = UrgentMedicalTerms();

      final keys = terms.entries.map((entry) => entry.id).toSet();
      expect(
        keys,
        containsAll(<String>{
          'pain_location',
          'pain_severity',
          'pain_quality',
          'pain_onset',
          'pain_duration',
        }),
      );

      expect(terms.painScalePhraseDe(8), contains('8 von 10'));
      expect(terms.painScalePhraseAr(8), contains('8 من 10'));
    });

    test('rejects pain scores outside zero to ten', () {
      const terms = UrgentMedicalTerms();

      expect(() => terms.painScalePhraseDe(-1), throwsRangeError);
      expect(() => terms.painScalePhraseAr(11), throwsRangeError);
    });
  });

  testWidgets('notdienst screen uses glass UI and explicit BiDi', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NotdienstDoctorScreen()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    final german = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == '116 117 & Apotheken-Notdienst',
      ),
    );
    expect(german.languageCode, 'de');

    final arabic = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == 'الطبيب والصيدلية المناوبة',
      ),
    );
    expect(arabic.languageCode, 'ar');
  });
}
