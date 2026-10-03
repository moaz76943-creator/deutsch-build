import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/doppelkonnektoren/application/doppelkonnektoren_notifier.dart';
import 'package:deutsch_bilarabi/features/doppelkonnektoren/data/local_doppelkonnektoren_repository.dart';
import 'package:deutsch_bilarabi/features/doppelkonnektoren/domain/doppelkonnektoren_models.dart';

void main() {
  group('Doppelkonnektor metadata', () {
    test('connector pairs expose the canonical two-part formulas', () {
      expect(
        DoppelConnectorType.jeDesto.firstPart,
        'je',
      );
      expect(
        DoppelConnectorType.jeDesto.secondPart,
        'desto',
      );
      expect(
        DoppelConnectorType.sowohlAlsAuch.formula,
        'sowohl … als auch',
      );
      expect(
        DoppelConnectorType.wederNoch.formula,
        'weder … noch',
      );
    });

    test('je desto requires comparative structure', () {
      expect(
        DoppelConnectorType.jeDesto.requiresComparative,
        isTrue,
      );
      expect(
        DoppelConnectorType.sowohlAlsAuch.requiresComparative,
        isFalse,
      );
      expect(
        DoppelConnectorType.wederNoch.requiresComparative,
        isFalse,
      );
    });
  });

  group('LocalDoppelkonnektorenRepository', () {
    test('validates je desto productivity sentence exactly', () async {
      const repository = LocalDoppelkonnektorenRepository();

      expect(
        await repository.validateConnectorPair(
          'je_desto_focus',
          'je',
          'desto',
        ),
        isTrue,
      );
      expect(
        await repository.validateSentence(
          'je_desto_focus',
          'Je klarer die Lernziele sind, desto effizienter arbeitet das Team.',
        ),
        isTrue,
      );
      expect(
        await repository.validateConnectorPair(
          'je_desto_focus',
          'sowohl',
          'als auch',
        ),
        isFalse,
      );
    });

    test('validates sowohl als auch additive structure', () async {
      const repository = LocalDoppelkonnektorenRepository();

      expect(
        await repository.validateConnectorPair(
          'sowohl_study_methods',
          'sowohl',
          'als auch',
        ),
        isTrue,
      );
      expect(
        await repository.validateSentence(
          'sowohl_study_methods',
          'Die Studie berücksichtigt sowohl die Lernzeit als auch die Schlafqualität.',
        ),
        isTrue,
      );
    });

    test('validates weder noch negative coordination', () async {
      const repository = LocalDoppelkonnektorenRepository();

      expect(
        await repository.validateConnectorPair(
          'weder_science_bias',
          'weder',
          'noch',
        ),
        isTrue,
      );
      expect(
        await repository.validateSentence(
          'weder_science_bias',
          'Die Auswertung zeigt weder einen Messfehler noch einen systematischen Bias.',
        ),
        isTrue,
      );
    });

    test('filters challenges by connector type', () async {
      const repository = LocalDoppelkonnektorenRepository();
      final challenges = await repository.getChallenges(
        type: DoppelConnectorType.wederNoch,
      );

      expect(challenges, isNotEmpty);
      expect(
        challenges.every(
          (item) => item.type == DoppelConnectorType.wederNoch,
        ),
        isTrue,
      );
    });
  });

  group('DoppelkonnektorenNotifier', () {
    test('loads deterministic first challenge and connector options',
        () async {
      final notifier = DoppelkonnektorenNotifier(
        const LocalDoppelkonnektorenRepository(),
      );
      addTearDown(notifier.dispose);

      await notifier.nextChallenge();

      expect(notifier.currentChallenge, isNotNull);
      expect(notifier.currentChallenge!.id, 'je_desto_focus');
      expect(notifier.connectorOptions, contains('je … desto'));
      expect(notifier.selectedConnector, isNull);
      expect(notifier.isCorrect, isNull);
    });

    test('correct pair updates feedback immediately', () async {
      final notifier = DoppelkonnektorenNotifier(
        const LocalDoppelkonnektorenRepository(),
      );
      addTearDown(notifier.dispose);
      await notifier.nextChallenge();

      await notifier.submitAnswer(
        'je … desto',
        'Je klarer die Lernziele sind, desto effizienter arbeitet das Team.',
      );

      expect(notifier.selectedConnector, 'je … desto');
      expect(notifier.isCorrect, isTrue);
      expect(notifier.feedbackExplanation, contains('Komparativ'));
      expect(notifier.feedbackExplanation, contains('الفعل'));
    });

    test('wrong sentence stays false even with correct connector', () async {
      final notifier = DoppelkonnektorenNotifier(
        const LocalDoppelkonnektorenRepository(),
      );
      addTearDown(notifier.dispose);
      await notifier.nextChallenge();

      await notifier.submitAnswer(
        'je … desto',
        'Je klarer die Lernziele, das Team desto effizienter arbeitet.',
      );

      expect(notifier.isCorrect, isFalse);
      expect(notifier.feedbackExplanation, isNotEmpty);
    });

    test('filter resets state and loads selected connector family', () async {
      final notifier = DoppelkonnektorenNotifier(
        const LocalDoppelkonnektorenRepository(),
      );
      addTearDown(notifier.dispose);
      await notifier.nextChallenge();

      await notifier.filterByType(
        DoppelConnectorType.sowohlAlsAuch,
      );

      expect(
        notifier.currentChallenge!.type,
        DoppelConnectorType.sowohlAlsAuch,
      );
      expect(notifier.connectorOptions, contains('sowohl … als auch'));
      expect(notifier.selectedConnector, isNull);
      expect(notifier.isCorrect, isNull);
    });
  });
}
