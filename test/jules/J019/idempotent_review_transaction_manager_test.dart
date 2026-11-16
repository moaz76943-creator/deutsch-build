import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/progress/idempotent_review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

void main() {
  group('IdempotentReviewTransactionManager J019 Tests', () {
    late IdempotentReviewTransactionManager manager;
    late List<ReviewTransactionEnvelope> persistedEnvelopes;
    late bool shouldFailPersistence;

    setUp(() {
      persistedEnvelopes = [];
      shouldFailPersistence = false;
      manager = IdempotentReviewTransactionManager(
        persistencePort: (envelope) async {
          if (shouldFailPersistence) {
            throw Exception('Simulated storage failure');
          }
          persistedEnvelopes.add(envelope);
        },
      );
    });

    test('should reject transaction with wrong language pair', () async {
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'de-ar',
      );

      final status = await manager.commitReview(envelope, activeLanguagePairKey: 'en-ar');

      expect(status.state, TransactionState.failed);
      expect(status.error, contains('Pair mismatch'));
      expect(persistedEnvelopes, isEmpty);
    });

    test('should process transaction successfully', () async {
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'de-ar',
      );

      final status = await manager.commitReview(envelope, activeLanguagePairKey: 'de-ar');

      expect(status.state, TransactionState.committed);
      expect(persistedEnvelopes, hasLength(1));
      expect(persistedEnvelopes.first, envelope);
    });

    test('identical retry yields idempotent result', () async {
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'de-ar',
      );

      final status1 = await manager.commitReview(envelope, activeLanguagePairKey: 'de-ar');
      expect(status1.state, TransactionState.committed);
      expect(persistedEnvelopes, hasLength(1));

      // Simulate a repeated tap / retry
      final status2 = await manager.commitReview(envelope, activeLanguagePairKey: 'de-ar');
      expect(status2.state, TransactionState.committed);
      expect(persistedEnvelopes, hasLength(1)); // No duplicate persistence
    });

    test('duplicate command with changed payload fails', () async {
      final timestamp = DateTime.now();
      final envelope1 = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 3,
        timestamp: timestamp,
        languagePairKey: 'de-ar',
      );

      final envelope2 = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 2, // Changed rating
        timestamp: timestamp,
        languagePairKey: 'de-ar',
      );

      final status1 = await manager.commitReview(envelope1, activeLanguagePairKey: 'de-ar');
      expect(status1.state, TransactionState.committed);

      final status2 = await manager.commitReview(envelope2, activeLanguagePairKey: 'de-ar');
      expect(status2.state, TransactionState.failed);
      expect(status2.error, 'Conflicting reviewEventId payload');
      expect(persistedEnvelopes, hasLength(1));
    });

    test('simulated storage failure transitions to recoverable state', () async {
      shouldFailPersistence = true;
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'de-ar',
      );

      final status = await manager.commitReview(envelope, activeLanguagePairKey: 'de-ar');

      expect(status.state, TransactionState.recoverable);
      expect(status.error, isA<Exception>());
      expect(persistedEnvelopes, isEmpty);

      final recoverable = manager.getRecoverableTransactions();
      expect(recoverable, hasLength(1));
      expect(recoverable.first.envelope.reviewEventId, 'event1');

      // Now fix storage and retry
      shouldFailPersistence = false;
      final retryStatus = await manager.commitReview(envelope, activeLanguagePairKey: 'de-ar');
      expect(retryStatus.state, TransactionState.committed);
      expect(persistedEnvelopes, hasLength(1));
    });
  });
}
