import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/relativsaetze/application/relativsaetze_notifier.dart';
import 'package:deutsch_bilarabi/features/relativsaetze/data/local_relativsaetze_repository.dart';
import 'package:deutsch_bilarabi/features/relativsaetze/domain/relativsaetze_models.dart';

void main() {
  group('relative pronoun grammar', () {
    test('resolves prepositional dative and accusative forms', () {
      expect(
        RelativeAntecedentGender.masculine.pronounFor(
          RelativePronounCase.dative,
        ),
        'dem',
      );
      expect(
        RelativeAntecedentGender.feminine.pronounFor(
          RelativePronounCase.accusative,
        ),
        'die',
      );
      expect(
        RelativeAntecedentGender.plural.pronounFor(
          RelativePronounCase.dative,
        ),
        'denen',
      );
    });

    test('resolves genitive dessen and deren from antecedent gender', () {
      expect(
        RelativeAntecedentGender.masculine.pronounFor(
          RelativePronounCase.genitive,
        ),
        'dessen',
      );
      expect(
        RelativeAntecedentGender.neuter.pronounFor(
          RelativePronounCase.genitive,
        ),
        'dessen',
      );
      expect(
        RelativeAntecedentGender.feminine.pronounFor(
          RelativePronounCase.genitive,
        ),
        'deren',
      );
      expect(
        RelativeAntecedentGender.plural.pronounFor(
          RelativePronounCase.genitive,
        ),
        'deren',
      );
    });
  });

  group('LocalRelativsaetzeRepository', () {
    test('validates mit + Dativ masculine and rejects Akkusativ', () async {
      const repository = LocalRelativsaetzeRepository();

      expect(
        await repository.validatePronoun('prep_mit_mann', 'dem'),
        isTrue,
      );
      expect(
        await repository.validatePronoun('prep_mit_mann', 'den'),
        isFalse,
      );
      expect(
        await repository.validateSentence(
          'prep_mit_mann',
          'Das ist der Mann, mit dem ich gestern gesprochen habe.',
        ),
        isTrue,
      );
    });

    test('validates auf + Akkusativ feminine', () async {
      const repository = LocalRelativsaetzeRepository();

      expect(
        await repository.validatePronoun('prep_auf_kollegin', 'die'),
        isTrue,
      );
      expect(
        await repository.validatePronoun('prep_auf_kollegin', 'der'),
        isFalse,
      );
    });

    test('validates genitive possession for masculine and feminine antecedents',
        () async {
      const repository = LocalRelativsaetzeRepository();

      expect(
        await repository.validatePronoun('genitiv_mann_auto', 'dessen'),
        isTrue,
      );
      expect(
        await repository.validatePronoun('genitiv_frau_tochter', 'deren'),
        isTrue,
      );
      expect(
        await repository.validatePronoun('genitiv_frau_tochter', 'dessen'),
        isFalse,
      );
    });

    test('filters challenges by focus without mixing categories', () async {
      const repository = LocalRelativsaetzeRepository();

      final genitive = await repository.getChallenges(
        focus: RelativeClauseFocus.genitivePossession,
      );

      expect(genitive, isNotEmpty);
      expect(
        genitive.every(
          (item) => item.focus == RelativeClauseFocus.genitivePossession,
        ),
        isTrue,
      );
    });
  });

  group('RelativsaetzeNotifier', () {
    test('loads deterministic first challenge and exposes answer options',
        () async {
      final notifier = RelativsaetzeNotifier(
        const LocalRelativsaetzeRepository(),
      );
      addTearDown(notifier.dispose);

      await notifier.nextChallenge();

      expect(notifier.currentChallenge, isNotNull);
      expect(notifier.currentChallenge!.id, 'prep_mit_mann');
      expect(notifier.options, contains('dem'));
      expect(notifier.selectedPronoun, isNull);
      expect(notifier.isCorrect, isNull);
    });

    test('correct answer updates feedback and correctness', () async {
      final notifier = RelativsaetzeNotifier(
        const LocalRelativsaetzeRepository(),
      );
      addTearDown(notifier.dispose);
      await notifier.nextChallenge();

      await notifier.submitAnswer(
        'dem',
        'Das ist der Mann, mit dem ich gestern gesprochen habe.',
      );

      expect(notifier.selectedPronoun, 'dem');
      expect(notifier.isCorrect, isTrue);
      expect(notifier.feedbackExplanation, contains('Dativ'));
      expect(notifier.feedbackExplanation, contains('نهاية'));
    });

    test('wrong sentence remains false even with correct pronoun', () async {
      final notifier = RelativsaetzeNotifier(
        const LocalRelativsaetzeRepository(),
      );
      addTearDown(notifier.dispose);
      await notifier.nextChallenge();

      await notifier.submitAnswer(
        'dem',
        'Das ist der Mann, mit dem ich habe gestern gesprochen.',
      );

      expect(notifier.isCorrect, isFalse);
      expect(notifier.feedbackExplanation, isNotEmpty);
    });

    test('filter resets state and loads genitive challenge', () async {
      final notifier = RelativsaetzeNotifier(
        const LocalRelativsaetzeRepository(),
      );
      addTearDown(notifier.dispose);
      await notifier.nextChallenge();

      await notifier.filterByFocus(
        RelativeClauseFocus.genitivePossession,
      );

      expect(
        notifier.currentChallenge!.focus,
        RelativeClauseFocus.genitivePossession,
      );
      expect(notifier.selectedPronoun, isNull);
      expect(notifier.isCorrect, isNull);
      expect(notifier.options, contains('dessen'));
    });
  });
}
