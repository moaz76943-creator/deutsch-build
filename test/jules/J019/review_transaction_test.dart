import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_state.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

void main() {
  group('ReviewTransactionManager', () {
    late ReviewTransactionManager manager;

    setUp(() {
      manager = ReviewTransactionManager();
    });

    test('rejects empty reviewId', () async {
      const command = ReviewCommand(
        reviewId: '',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'card_1',
        facetKey: 'front',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      final state = await manager.executeTransaction(command, (env) async {});

      expect(state, isA<TransactionFailed>());
      expect((state as TransactionFailed).error, isA<ArgumentError>());
    });

    test('strict A->B and B->A separation', () async {
      const commandAB = ReviewCommand(
        reviewId: 'rev_1',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'card_1',
        facetKey: 'front',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      final stateAB = await manager.executeTransaction(commandAB, (env) async {});
      expect(stateAB, isA<TransactionCommitted>());

      const commandBA = ReviewCommand(
        reviewId: 'rev_1', // Same ID, but different pair!
        sourceLanguageId: 'de',
        targetLanguageId: 'en',
        cardId: 'card_1',
        facetKey: 'front',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      // Should reject because ID already used for a different pair
      final stateBA = await manager.executeTransaction(commandBA, (env) async {});
      expect(stateBA, isA<TransactionFailed>());
      expect(((stateBA as TransactionFailed).error as StateError).message, contains('different language pair'));
    });

    test('repeated taps (pending state rejection)', () async {
      const command = ReviewCommand(
        reviewId: 'rev_2',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'card_1',
        facetKey: 'front',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      // We use a completer to hold the transaction in pending state
      final completer = Future.delayed(const Duration(milliseconds: 100));

      final future1 = manager.executeTransaction(command, (env) async {
        await completer;
      });

      // Immediately execute the second one
      final state2 = await manager.executeTransaction(command, (env) async {});

      expect(state2, isA<TransactionFailed>());
      expect(((state2 as TransactionFailed).error as StateError).message, contains('already pending'));

      await future1; // wait for the first to finish
    });

    test('idempotency (same command retried after commit)', () async {
      const command = ReviewCommand(
        reviewId: 'rev_3',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'card_1',
        facetKey: 'front',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      int commitCount = 0;
      Future<void> commitFn(ReviewTransactionEnvelope env) async {
        commitCount++;
      }

      final state1 = await manager.executeTransaction(command, commitFn);
      expect(state1, isA<TransactionCommitted>());
      expect(commitCount, 1);

      final state2 = await manager.executeTransaction(command, commitFn);
      expect(state2, isA<TransactionCommitted>());
      expect(commitCount, 1); // Should not increase
    });

    test('history restoration', () async {
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'rev_restored',
        learnerContentKey: 'card_1',
        rating: ReviewRating.good.index,
        timestamp: DateTime.now(),
        languagePairKey: 'en_de',
      );

      manager.restoreHistory([envelope]);

      const command = ReviewCommand(
        reviewId: 'rev_restored',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'card_1',
        facetKey: 'front',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      int commitCount = 0;
      final state = await manager.executeTransaction(command, (env) async {
        commitCount++;
      });

      expect(state, isA<TransactionCommitted>());
      expect(commitCount, 0); // Intercepted as already committed
    });

    test('recovery of a failed operation', () async {
      const command = ReviewCommand(
        reviewId: 'rev_4',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'card_1',
        facetKey: 'front',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      bool shouldFail = true;
      final state1 = await manager.executeTransaction(command, (env) async {
        if (shouldFail) {
          throw Exception('Storage failed');
        }
      });

      expect(state1, isA<TransactionRecoverable>());

      shouldFail = false;
      final state2 = await manager.executeTransaction(command, (env) async {});

      expect(state2, isA<TransactionCommitted>());
    });
  });
}
