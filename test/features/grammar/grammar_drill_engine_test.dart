import 'package:deutsch_bilarabi/features/grammar/application/grammar_drill_notifier.dart';
import 'package:deutsch_bilarabi/features/grammar/application/sentence_token_bank.dart';
import 'package:deutsch_bilarabi/features/grammar/data/local_grammar_drill_repository.dart';
import 'package:deutsch_bilarabi/features/grammar/domain/grammar_drill_evaluator.dart';
import 'package:deutsch_bilarabi/features/grammar/domain/grammar_drill_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = LocalGrammarDrillRepository();
  const evaluator = GrammarDrillEvaluator();

  group('LocalGrammarDrillRepository', () {
    test('resolves only the approved Arabic to German directed pair', () {
      expect(
        LocalGrammarDrillRepository.forDirectedPair(
          sourceLocale: 'ar',
          targetLocale: 'de-DE',
        ),
        isA<LocalGrammarDrillRepository>(),
      );
      expect(
        LocalGrammarDrillRepository.forDirectedPair(
          sourceLocale: 'en',
          targetLocale: 'de-DE',
        ),
        isNull,
      );
      expect(
        LocalGrammarDrillRepository.forDirectedPair(
          sourceLocale: 'ar',
          targetLocale: 'fr-FR',
        ),
        isNull,
      );
    });

    test('domain models all four German grammatical cases', () {
      expect(
        GrammarCase.values.map((value) => value.label),
        containsAll(<String>['Nominativ', 'Akkusativ', 'Dativ', 'Genitiv']),
      );
    });

    test('provides all required drill types for every supported level', () {
      for (final level in GrammarLevel.values) {
        final drills = repository.forLevel(level);
        expect(drills, isNotEmpty);
        expect(
          drills.whereType<SentenceReorderExercise>(),
          isNotEmpty,
          reason: '${level.code} must include sentence reordering',
        );
        expect(
          drills.whereType<VerbConjugationDrill>(),
          isNotEmpty,
          reason: '${level.code} must include verb conjugation',
        );
        expect(
          drills.whereType<CaseSelectionDrill>(),
          isNotEmpty,
          reason: '${level.code} must include case selection',
        );
        expect(drills.every((drill) => drill.level == level), isTrue);
      }
    });

    test('lookup returns an exact drill and rejects unknown ids', () {
      final drill = repository.byId('a1-order-heute-deutsch');
      expect(drill, isA<SentenceReorderExercise>());
      expect(repository.byId('missing-id'), isNull);
    });
  });

  group('GrammarDrillEvaluator sentence reorder', () {
    final exercise = repository.byId('a1-order-heute-deutsch')
        as SentenceReorderExercise;

    test('token bank is shuffled independently of the canonical answer', () {
      final shuffled = SentenceTokenBank.shuffled(exercise, seed: 7);
      final shuffledIds = shuffled.map((token) => token.id).toList();

      expect(shuffledIds.toSet(), exercise.correctTokenIds.toSet());
      expect(shuffledIds, isNot(equals(exercise.correctTokenIds)));
    });

    test('accepts the canonical token order', () {
      final result = evaluator.evaluate(
        exercise,
        exercise.correctTokenIds,
      );

      expect(result.correct, isTrue);
      expect(result.score, 100);
    });

    test('rejects a sentence with the verb in the wrong position', () {
      final wrong = [...exercise.correctTokenIds];
      final verb = wrong.removeAt(1);
      wrong.add(verb);

      final result = evaluator.evaluate(exercise, wrong);

      expect(result.correct, isFalse);
      expect(result.feedbackAr, contains('ترتيب'));
    });

    test('rejects duplicate or missing tokens', () {
      final wrong = [
        exercise.correctTokenIds.first,
        exercise.correctTokenIds.first,
      ];

      expect(evaluator.evaluate(exercise, wrong).correct, isFalse);
    });
  });

  group('GrammarDrillEvaluator verb conjugation', () {
    test('accepts normalized exact conjugation including umlaut', () {
      final exercise =
          repository.byId('a2-verb-fahren-du') as VerbConjugationDrill;

      expect(evaluator.evaluate(exercise, '  FÄHRST. ').correct, isTrue);
    });

    test('does not silently accept an infinitive for a finite verb', () {
      final exercise =
          repository.byId('a2-verb-fahren-du') as VerbConjugationDrill;

      final result = evaluator.evaluate(exercise, 'fahren');

      expect(result.correct, isFalse);
      expect(result.feedbackAr, contains('التصريف'));
    });

    test('accepts configured equivalent forms only', () {
      final exercise = VerbConjugationDrill(
        id: 'accepted-form',
        level: GrammarLevel.b1,
        titleAr: 'اختبار',
        instructionAr: 'صرّف',
        reinforcementAr: 'ممتاز',
        infinitive: 'sein',
        pronoun: 'Sie',
        sentencePrefix: 'Sie',
        sentenceSuffix: 'bereit.',
        expectedForm: 'sind',
        acceptedForms: const ['sind'],
      );

      expect(evaluator.evaluate(exercise, 'sind').correct, isTrue);
      expect(evaluator.evaluate(exercise, 'ist').correct, isFalse);
    });
  });

  group('GrammarDrillEvaluator case selection', () {
    test('distinguishes Akkusativ from Dativ articles', () {
      final accusative =
          repository.byId('a1-case-mantel') as CaseSelectionDrill;
      final dative =
          repository.byId('a2-case-mit-bus') as CaseSelectionDrill;

      expect(evaluator.evaluate(accusative, 'den').correct, isTrue);
      expect(evaluator.evaluate(accusative, 'dem').correct, isFalse);
      expect(evaluator.evaluate(dative, 'dem').correct, isTrue);
      expect(evaluator.evaluate(dative, 'den').correct, isFalse);
    });
  });

  group('GrammarDrillNotifier', () {
    test('awards points and positive reinforcement after a correct answer', () {
      final exercise = repository.byId('a1-order-heute-deutsch')!;
      final notifier = GrammarDrillNotifier([exercise]);
      final reorder = exercise as SentenceReorderExercise;

      for (final id in reorder.correctTokenIds) {
        notifier.addSentenceToken(id);
      }
      notifier.checkAnswer();

      expect(notifier.state.isAnswered, isTrue);
      expect(notifier.state.lastAnswerCorrect, isTrue);
      expect(notifier.state.points, greaterThanOrEqualTo(100));
      expect(notifier.state.correctCount, 1);
      expect(notifier.state.feedbackAr, isNotEmpty);
      notifier.dispose();
    });

    test('never subtracts points after an incorrect answer', () {
      final exercise = repository.byId('a1-verb-sein-ich')!;
      final notifier = GrammarDrillNotifier([exercise]);

      notifier.setAnswer('bist');
      notifier.checkAnswer();

      expect(notifier.state.lastAnswerCorrect, isFalse);
      expect(notifier.state.points, 0);
      expect(notifier.state.attempts, 1);
      notifier.dispose();
    });

    test('retry clears interaction state and preserves score', () {
      final exercise = repository.byId('a1-verb-sein-ich')!;
      final notifier = GrammarDrillNotifier([exercise]);

      notifier.setAnswer('bin');
      notifier.checkAnswer();
      final score = notifier.state.points;
      notifier.retry();

      expect(notifier.state.isAnswered, isFalse);
      expect(notifier.state.selectedAnswer, isEmpty);
      expect(notifier.state.feedbackAr, isEmpty);
      expect(notifier.state.points, score);
      notifier.dispose();
    });

    test('next advances through the queue and marks completion at the end', () {
      final drills = repository.forLevel(GrammarLevel.a1).take(2).toList();
      final notifier = GrammarDrillNotifier(drills);

      notifier.next();
      expect(notifier.state.currentIndex, 1);
      notifier.next();
      expect(notifier.state.completed, isTrue);
      notifier.dispose();
    });

    test('rejects an empty exercise queue', () {
      expect(
        () => GrammarDrillNotifier(const <GrammarDrill>[]),
        throwsArgumentError,
      );
    });
  });
}
