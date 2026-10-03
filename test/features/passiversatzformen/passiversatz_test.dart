import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/passiversatzformen/application/passiversatz_engine.dart';
import 'package:deutsch_bilarabi/features/passiversatzformen/domain/passiversatz_models.dart';
import 'package:deutsch_bilarabi/features/passiversatzformen/presentation/passiversatz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PassiversatzEngine', () {
    const engine = PassiversatzEngine();

    test('covers all required passive alternative families', () {
      final forms = engine.challenges
          .expand((challenge) => challenge.alternatives)
          .map((alternative) => alternative.form)
          .toSet();

      expect(forms, contains(PassiversatzForm.sichLassen));
      expect(forms, contains(PassiversatzForm.seinZuInfinitiv));
      expect(forms, contains(PassiversatzForm.adjective));
    });

    test('transforms the canonical problem example into all alternatives', () {
      final challenge = engine.byId('problem_loesen');

      expect(challenge.passiveSentence, 'Das Problem kann gelöst werden.');
      expect(
        challenge.alternativeFor(PassiversatzForm.sichLassen)!.sentence,
        'Das Problem lässt sich lösen.',
      );
      expect(
        challenge.alternativeFor(PassiversatzForm.seinZuInfinitiv)!.sentence,
        'Das Problem ist zu lösen.',
      );
      expect(
        challenge.alternativeFor(PassiversatzForm.adjective)!.sentence,
        'Das Problem ist lösbar.',
      );
    });

    test('normalizes harmless spacing, case, and final punctuation', () {
      final challenge = engine.byId('problem_loesen');

      final evaluation = engine.evaluate(
        challenge: challenge,
        form: PassiversatzForm.sichLassen,
        answer: '  das   PROBLEM lässt sich lösen  ',
      );

      expect(evaluation.isCorrect, isTrue);
      expect(evaluation.expected, 'Das Problem lässt sich lösen.');
    });

    test('rejects an answer that changes the target construction', () {
      final challenge = engine.byId('sicherheitsregeln_beachten');

      final evaluation = engine.evaluate(
        challenge: challenge,
        form: PassiversatzForm.seinZuInfinitiv,
        answer: 'Die Sicherheitsregeln lassen sich beachten.',
      );

      expect(evaluation.isCorrect, isFalse);
      expect(
        evaluation.expected,
        'Die Sicherheitsregeln sind im Labor zu beachten.',
      );
    });

    test('contains academic or scientific contexts only', () {
      final contexts = engine.challenges.map((item) => item.contextAr).join(' ');

      expect(contexts, contains('بحث'));
      expect(contexts, contains('مختبر'));
      expect(
        engine.challenges.every(
          (challenge) =>
              !challenge.passiveSentence.toLowerCase().contains('alkohol') &&
              !challenge.passiveSentence.toLowerCase().contains('nachtclub'),
        ),
        isTrue,
      );
    });

    test('includes both -bar and -lich adjective alternatives', () {
      final adjectiveSentences = engine.challenges
          .expand((challenge) => challenge.alternatives)
          .where((alternative) => alternative.form == PassiversatzForm.adjective)
          .map((alternative) => alternative.sentence)
          .join(' ');

      expect(adjectiveSentences, contains('lösbar'));
      expect(adjectiveSentences, contains('verständlich'));
    });
  });

  testWidgets('screen uses glass cards, safe scrolling, and explicit BiDi', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PassiversatzScreen()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    final german = tester.widget<Directionality>(
      find.byKey(const ValueKey<String>('passiversatz-german-direction')),
    );
    final arabic = tester.widget<Directionality>(
      find.byKey(const ValueKey<String>('passiversatz-arabic-direction')),
    );

    expect(german.textDirection, TextDirection.ltr);
    expect(arabic.textDirection, TextDirection.rtl);
  });
}
