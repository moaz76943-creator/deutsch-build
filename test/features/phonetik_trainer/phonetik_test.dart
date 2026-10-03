import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/phonetik_trainer/application/phonetik_engine.dart';
import 'package:deutsch_bilarabi/features/phonetik_trainer/data/phonetik_catalog.dart';
import 'package:deutsch_bilarabi/features/phonetik_trainer/presentation/phonetik_trainer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhonetikTrainerEngine', () {
    test('catalog covers every required phonetics focus', () {
      final ids = PhonetikCatalog.focuses.map((focus) => focus.id).toSet();

      expect(
        ids,
        containsAll(<String>{
          'ich-ach',
          'umlaut-a',
          'umlaut-o',
          'umlaut-u',
          'sp-st',
          'stress-intonation',
        }),
      );
    });

    test('evaluates a correct ich/ach answer with focused feedback', () {
      final engine = PhonetikTrainerEngine.standard();

      final result = engine.evaluate(
        focusId: 'ich-ach',
        selectedChoice: 'Buch',
      );

      expect(result.isCorrect, isTrue);
      expect(result.expectedChoice, 'Buch');
      expect(result.feedbackAr, contains('[x]'));
    });

    test('rejects a choice that is not part of the exercise', () {
      final engine = PhonetikTrainerEngine.standard();

      expect(
        () => engine.evaluate(
          focusId: 'umlaut-u',
          selectedChoice: 'Haus',
        ),
        throwsArgumentError,
      );
    });

    test('practice order moves completed focuses behind new material', () {
      final engine = PhonetikTrainerEngine.standard();

      final ordered = engine.practiceOrder(<String>{'ich-ach', 'umlaut-a'});

      expect(ordered.first.id, 'umlaut-o');
      expect(ordered[ordered.length - 2].id, 'ich-ach');
      expect(ordered.last.id, 'umlaut-a');
    });

    test('catalog stays neutral and family friendly', () {
      const blockedTerms = <String>{
        'Bier',
        'Wein',
        'Bar',
        'Nachtclub',
      };

      final corpus = <String>[
        for (final focus in PhonetikCatalog.focuses) ...<String>[
          focus.titleDe,
          focus.titleAr,
          focus.articulationAr,
          focus.exercise.promptAr,
          focus.exercise.explanationAr,
          ...focus.exercise.choices,
          for (final example in focus.examples) ...<String>[
            example.word,
            example.ipa,
            example.hintAr,
          ],
        ],
      ].join(' ');

      for (final term in blockedTerms) {
        expect(corpus, isNot(contains(term)));
      }
    });
  });

  testWidgets('screen uses glass cards, scrolling, safe area, and explicit BiDi',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PhonetikTrainerScreen(
          engine: PhonetikTrainerEngine.standard(),
        ),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsNWidgets(7));

    final germanIntro = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == 'Phonetik & Aussprache',
      ),
    );
    expect(germanIntro.languageCode, 'de');

    final arabicIntro = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text.startsWith('تدريب مركز على موضع اللسان'),
      ),
    );
    expect(arabicIntro.languageCode, 'ar');
  });
}
