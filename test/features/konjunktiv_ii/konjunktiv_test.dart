import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/konjunktiv_ii/application/konjunktiv_notifier.dart';
import 'package:deutsch_bilarabi/features/konjunktiv_ii/data/local_konjunktiv_repository.dart';
import 'package:deutsch_bilarabi/features/konjunktiv_ii/domain/konjunktiv_models.dart';

void main() {
  group('LocalKonjunktivRepository', () {
    test('validates wäre, hätte and könnte core forms precisely', () async {
      final repository = LocalKonjunktivRepository();

      expect(
        await repository.validateConjugation('wish_sein_ich', 'wäre'),
        isTrue,
      );
      expect(
        await repository.validateConjugation('wish_haben_ich', 'hätte'),
        isTrue,
      );
      expect(
        await repository.validateConjugation('wish_koennen_ich', 'könnte'),
        isTrue,
      );

      expect(
        await repository.validateConjugation('wish_sein_ich', 'war'),
        isFalse,
      );
      expect(
        await repository.validateConjugation('wish_haben_ich', 'hatte'),
        isFalse,
      );
      expect(
        await repository.validateConjugation('wish_koennen_ich', 'kann'),
        isFalse,
      );
    });

    test('validates würde plus infinitive as one construction', () async {
      final repository = LocalKonjunktivRepository();

      expect(
        await repository.validateConjugation(
          'hypothetical_reisen_ich',
          'würde reisen',
        ),
        isTrue,
      );
      expect(
        await repository.validateConjugation(
          'hypothetical_reisen_ich',
          'würde gereist',
        ),
        isFalse,
      );
      expect(
        await repository.validateSentence(
          'hypothetical_reisen_ich',
          'Wenn ich mehr Urlaub hätte, würde ich öfter reisen.',
        ),
        isTrue,
      );
    });

    test('usage filter returns only requested challenge category', () async {
      final repository = LocalKonjunktivRepository();
      final advice = await repository.getChallenges(
        usage: KonjunktivUsage.advice,
      );

      expect(advice, isNotEmpty);
      expect(
        advice.every((item) => item.usage == KonjunktivUsage.advice),
        isTrue,
      );
    });

    test('challenge bank covers at least twenty common target verbs', () async {
      final repository = LocalKonjunktivRepository();
      final challenges = await repository.getChallenges();
      final verbs = challenges.map((item) => item.targetVerb).toSet();

      expect(verbs.length, greaterThanOrEqualTo(20));
    });
  });

  group('KonjunktivNotifier', () {
    test('nextChallenge exposes options and clears previous answer state',
        () async {
      final notifier = KonjunktivNotifier(LocalKonjunktivRepository());
      addTearDown(notifier.dispose);

      await notifier.nextChallenge();

      expect(notifier.currentChallenge, isNotNull);
      expect(notifier.currentChallenge!.id, 'polite_koennen_sie');
      expect(notifier.options, contains('könnten'));
      expect(notifier.selectedAnswer, isNull);
      expect(notifier.isCorrect, isNull);
      expect(notifier.feedbackExplanation, isNull);
    });

    test('checkKonjunktivAnswer updates selected answer and feedback', () async {
      final notifier = KonjunktivNotifier(LocalKonjunktivRepository());
      addTearDown(notifier.dispose);
      await notifier.nextChallenge();

      await notifier.checkKonjunktivAnswer(
        'könnten',
        'Könnten Sie mir bitte die Rechnung bringen?',
      );

      expect(notifier.selectedAnswer, 'könnten');
      expect(notifier.isCorrect, isTrue);
      expect(notifier.feedbackExplanation, isNotEmpty);
      expect(notifier.feedbackExplanation, contains('könnten'));
    });

    test('wrong construction stays false even when conjugation is correct',
        () async {
      final notifier = KonjunktivNotifier(LocalKonjunktivRepository());
      addTearDown(notifier.dispose);
      await notifier.nextChallenge();

      await notifier.checkKonjunktivAnswer(
        'könnten',
        'Sie könnten mir bitte die Rechnung bringen.',
      );

      expect(notifier.selectedAnswer, 'könnten');
      expect(notifier.isCorrect, isFalse);
      expect(notifier.feedbackExplanation, isNotEmpty);
    });

    test('filterByUsage reloads challenges and resets state', () async {
      final notifier = KonjunktivNotifier(LocalKonjunktivRepository());
      addTearDown(notifier.dispose);
      await notifier.nextChallenge();

      await notifier.filterByUsage(KonjunktivUsage.advice);

      expect(notifier.activeUsage, KonjunktivUsage.advice);
      expect(notifier.currentChallenge, isNotNull);
      expect(notifier.currentChallenge!.usage, KonjunktivUsage.advice);
      expect(notifier.currentChallenge!.id, 'advice_sollen_du');
      expect(notifier.options, contains('solltest'));
      expect(notifier.selectedAnswer, isNull);
      expect(notifier.isCorrect, isNull);
    });
  });
}
