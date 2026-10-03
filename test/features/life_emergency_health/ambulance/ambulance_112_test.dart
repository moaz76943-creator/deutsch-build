import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/ambulance/ambulance_112_phrase_bank.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/ambulance/ambulance_112_screen.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/ambulance/ambulance_112_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/ambulance/ambulance_112_w_questions.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/emergency_health_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ambulance112WQuestions', () {
    test('provides exactly five practical W-questions', () {
      const guide = Ambulance112WQuestions();

      expect(guide.questions, hasLength(5));
      expect(guide.questions.map((item) => item.keywordDe), <String>[
        'Wo?',
        'Was?',
        'Wie viele?',
        'Welche?',
        'Warten!',
      ]);
      expect(guide.questions.last.promptDe, contains('Rückfragen'));
    });

    test('keeps caller identity available outside the five-question sequence', () {
      const guide = Ambulance112WQuestions();

      expect(guide.callerIdentityDe, contains('Mein Name ist'));
      expect(guide.callerIdentityAr, isNotEmpty);
    });
  });

  group('Ambulance112SubAgent', () {
    test('exposes life-threatening scenarios with German and Arabic support', () {
      const agent = Ambulance112SubAgent();

      expect(agent.domain, EmergencyHealthDomain.ambulance112);
      expect(agent.items, isNotEmpty);
      expect(
        agent.items.every(
          (item) => item.urgency == EmergencyUrgency.lifeThreatening,
        ),
        isTrue,
      );

      final ids = agent.items.map((item) => item.id).toSet();
      expect(
        ids,
        containsAll(<String>{
          'ambulance_request',
          'ambulance_unconscious',
          'ambulance_breathing',
          'ambulance_bleeding',
          'ambulance_accident',
        }),
      );
    });

    test('phrase bank contains location and acute-condition language', () {
      final corpus = Ambulance112PhraseBank.items
          .expand(
            (item) => <String>[
              item.german,
              item.arabic,
              item.explanationAr,
              ...item.tags,
            ],
          )
          .join(' ');

      expect(corpus, contains('112'));
      expect(corpus, contains('bewusstlos'));
      expect(corpus, contains('Atemnot'));
      expect(corpus, contains('starke Blutung'));
      expect(corpus, contains('Straße'));
    });
  });

  testWidgets('ambulance screen uses glass UI and explicit BiDi', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Ambulance112Screen()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    final german = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == 'Notruf 112: klar und kurz sprechen',
      ),
    );
    expect(german.languageCode, 'de');

    final arabic = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == 'اتصال الإسعاف 112',
      ),
    );
    expect(arabic.languageCode, 'ar');
  });
}
