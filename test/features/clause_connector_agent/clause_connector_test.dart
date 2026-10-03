import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/clause_connector_agent/application/clause_connector_notifier.dart';
import 'package:deutsch_bilarabi/features/clause_connector_agent/data/local_clause_connector_repository.dart';
import 'package:deutsch_bilarabi/features/clause_connector_agent/domain/clause_connector_models.dart';

void main() {
  group('LocalClauseConnectorRepository', () {
    test('weil is a verb-kicker while denn keeps verb position two', () async {
      final repository = LocalClauseConnectorRepository();
      final challenges = await repository.getChallenges();

      final weil = challenges.singleWhere(
        (item) => item.id == 'weil_krank',
      );
      final denn = challenges.singleWhere(
        (item) => item.id == 'denn_krank',
      );

      expect(weil.type, ConjunctionType.verbKicker);
      expect(denn.type, ConjunctionType.positionZero);
      expect(
        weil.arabicVerbPositionExplanation,
        contains('نهاية'),
      );
      expect(
        denn.arabicVerbPositionExplanation,
        contains('الموضع الثاني'),
      );
    });

    test('weil requires verb-final order and rejects main-clause order',
        () async {
      final repository = LocalClauseConnectorRepository();

      expect(
        await repository.validateConnection(
          'weil_krank',
          'Ich bleibe zu Hause, weil ich krank bin.',
        ),
        isTrue,
      );
      expect(
        await repository.validateConnection(
          'weil_krank',
          'Ich bleibe zu Hause, weil ich bin krank.',
        ),
        isFalse,
      );
    });

    test('denn preserves verb-second order and rejects verb-final order',
        () async {
      final repository = LocalClauseConnectorRepository();

      expect(
        await repository.validateConnection(
          'denn_krank',
          'Ich bleibe zu Hause, denn ich bin krank.',
        ),
        isTrue,
      );
      expect(
        await repository.validateConnection(
          'denn_krank',
          'Ich bleibe zu Hause, denn ich krank bin.',
        ),
        isFalse,
      );
    });

    test('type filtering returns only the requested conjunction family',
        () async {
      final repository = LocalClauseConnectorRepository();
      final verbKickers = await repository.getChallenges(
        type: ConjunctionType.verbKicker,
      );

      expect(verbKickers, isNotEmpty);
      expect(
        verbKickers.every(
          (item) => item.type == ConjunctionType.verbKicker,
        ),
        isTrue,
      );
    });
  });

  group('ClauseConnectorNotifier', () {
    test('correct connector and verb position produce positive feedback',
        () async {
      final notifier = ClauseConnectorNotifier(
        LocalClauseConnectorRepository(),
      );
      addTearDown(notifier.dispose);

      await notifier.nextChallenge();
      expect(notifier.currentChallenge?.id, 'weil_krank');
      expect(notifier.options, contains('weil'));

      await notifier.submitConnector(
        'weil',
        ClauseConnectorNotifier.verbFinalPosition,
      );

      expect(notifier.isCorrect, isTrue);
      expect(notifier.feedbackExplanation, contains('نهاية'));
    });

    test('wrong verb position is rejected even with the correct connector',
        () async {
      final notifier = ClauseConnectorNotifier(
        LocalClauseConnectorRepository(),
      );
      addTearDown(notifier.dispose);

      await notifier.nextChallenge();
      await notifier.submitConnector(
        'weil',
        ClauseConnectorNotifier.verbSecondPosition,
      );

      expect(notifier.isCorrect, isFalse);
      expect(notifier.feedbackExplanation, contains('نهاية'));
    });

    test('next challenge resets answer state and advances deterministically',
        () async {
      final notifier = ClauseConnectorNotifier(
        LocalClauseConnectorRepository(),
      );
      addTearDown(notifier.dispose);

      await notifier.nextChallenge();
      await notifier.submitConnector(
        'weil',
        ClauseConnectorNotifier.verbFinalPosition,
      );
      expect(notifier.isCorrect, isTrue);

      await notifier.nextChallenge();

      expect(notifier.currentChallenge?.id, 'denn_krank');
      expect(notifier.isCorrect, isNull);
      expect(notifier.feedbackExplanation, isNull);
      expect(notifier.options, contains('denn'));
    });
  });
}
