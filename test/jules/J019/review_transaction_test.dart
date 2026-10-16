import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/progress/idempotent_review_transaction_manager.dart';

void main() {
  group('IdempotentReviewTransactionManager', () {
    test('A->B is tested independently from B->A (Pair mismatch)', () async {
      final manager = IdempotentReviewTransactionManager();
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: '1',
        learnerContentKey: 'key',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'DE->EN',
      );
      final result = await manager.commitReview(envelope, activeLanguagePairKey: 'EN->DE');

      expect(result.state, TransactionState.failed);
      expect(result.error, contains('Pair mismatch'));
    });

    test('Empty reviewEventId fails validation', () async {
      final manager = IdempotentReviewTransactionManager();
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: '',
        learnerContentKey: 'key',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'DE->EN',
      );
      final result = await manager.commitReview(envelope, activeLanguagePairKey: 'DE->EN');

      expect(result.state, TransactionState.failed);
      expect(result.error, contains('Invalid reviewEventId'));
    });

    test('Repeated taps with identical reviewEventId are idempotent', () async {
      int persistCount = 0;
      final manager = IdempotentReviewTransactionManager(
        persistencePort: (env) async {
          persistCount++;
        },
      );

      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'idempotent-1',
        learnerContentKey: 'key',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'DE->EN',
      );

      // First submit
      final result1 = await manager.commitReview(envelope, activeLanguagePairKey: 'DE->EN');
      expect(result1.state, TransactionState.committed);
      expect(persistCount, 1);

      // Second submit (repeated tap)
      final result2 = await manager.commitReview(envelope, activeLanguagePairKey: 'DE->EN');
      expect(result2.state, TransactionState.committed);
      expect(persistCount, 1); // Persist count should not increase
    });

    test('Stale review commands are rejected', () async {
      final manager = IdempotentReviewTransactionManager(
        persistencePort: (env) async {},
      );

      final now = DateTime.now();

      // Submit a review for 'key1' at `now`
      final envelope1 = ReviewTransactionEnvelope(
        reviewEventId: 'ev-1',
        learnerContentKey: 'key1',
        rating: 3,
        timestamp: now,
        languagePairKey: 'DE->EN',
      );
      await manager.commitReview(envelope1, activeLanguagePairKey: 'DE->EN');

      // Submit an older review for 'key1' (stale)
      final envelope2 = ReviewTransactionEnvelope(
        reviewEventId: 'ev-2',
        learnerContentKey: 'key1',
        rating: 4,
        timestamp: now.subtract(const Duration(hours: 1)),
        languagePairKey: 'DE->EN',
      );
      final result2 = await manager.commitReview(envelope2, activeLanguagePairKey: 'DE->EN');

      expect(result2.state, TransactionState.failed);
      expect(result2.error, contains('Stale review command'));
    });

    test('Simulated storage failures are marked as recoverable', () async {
      bool shouldFail = true;
      final manager = IdempotentReviewTransactionManager(
        persistencePort: (env) async {
          if (shouldFail) {
            throw Exception('Storage failed');
          }
        },
      );

      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'fail-1',
        learnerContentKey: 'key',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'DE->EN',
      );

      // First submit - fails
      final result1 = await manager.commitReview(envelope, activeLanguagePairKey: 'DE->EN');
      expect(result1.state, TransactionState.recoverable);
      expect(manager.getRecoverableTransactions().length, 1);

      // Storage restores
      shouldFail = false;

      // Retry same transaction
      final result2 = await manager.commitReview(envelope, activeLanguagePairKey: 'DE->EN');
      expect(result2.state, TransactionState.committed);
      expect(manager.getRecoverableTransactions().length, 0);
    });

    test('LRU cache limits history size to 1000', () async {
      final manager = IdempotentReviewTransactionManager(
        persistencePort: (env) async {},
      );

      // Insert 1001 transactions
      for (int i = 0; i < 1001; i++) {
        final envelope = ReviewTransactionEnvelope(
          reviewEventId: 'ev-$i',
          learnerContentKey: 'key-$i',
          rating: 3,
          timestamp: DateTime.now(),
          languagePairKey: 'DE->EN',
        );
        await manager.commitReview(envelope, activeLanguagePairKey: 'DE->EN');
      }

      // First inserted item should have been evicted
      final oldEnvelope = ReviewTransactionEnvelope(
        reviewEventId: 'ev-0',
        learnerContentKey: 'key-0',
        rating: 3,
        timestamp: DateTime.now(), // update time so it's not stale
        languagePairKey: 'DE->EN',
      );

      // Attempt to re-commit the evicted event. It should process normally as a new event, not return the cached result.
      int persistCount = 0;
      final managerCheck = IdempotentReviewTransactionManager(
        persistencePort: (env) async {
           persistCount++;
        },
      );

       // Re-inserting with a fresh manager to test cache limit logic explicitly:
      for (int i = 0; i < 1001; i++) {
        final env = ReviewTransactionEnvelope(
          reviewEventId: 'ev-$i',
          learnerContentKey: 'key-$i',
          rating: 3,
          timestamp: DateTime.now(),
          languagePairKey: 'DE->EN',
        );
        await managerCheck.commitReview(env, activeLanguagePairKey: 'DE->EN');
      }

      expect(persistCount, 1001);

      // Attempt to commit 'ev-0' again, if it was evicted it will run persistence again
      final env0 = ReviewTransactionEnvelope(
        reviewEventId: 'ev-0',
        learnerContentKey: 'key-0',
        rating: 3,
        timestamp: DateTime.now().add(const Duration(minutes: 1)),
        languagePairKey: 'DE->EN',
      );

      await managerCheck.commitReview(env0, activeLanguagePairKey: 'DE->EN');
      expect(persistCount, 1002); // Successfully re-persisted since the previous one was evicted
    });
  });
}
