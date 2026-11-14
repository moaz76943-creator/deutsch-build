import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/progress/idempotent_review_transaction_manager.dart';
import 'dart:async';

void main() {
  group('IdempotentReviewTransactionManager', () {
    late IdempotentReviewTransactionManager manager;
    late List<ReviewTransactionEnvelope> persistedEnvelopes;
    late bool shouldFailPersistence;
    late Completer<void>? persistenceDelay;

    setUp(() {
      persistedEnvelopes = [];
      shouldFailPersistence = false;
      persistenceDelay = null;
      manager = IdempotentReviewTransactionManager(
        persistencePort: (envelope) async {
          if (persistenceDelay != null) {
            await persistenceDelay!.future;
          }
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
        languagePairKey: 'de_ar',
      );

      final status = await manager.commitReview(envelope, activeLanguagePairKey: 'en_ar');

      expect(status.state, TransactionState.failed);
      expect(status.error, isA<String>());
      expect((status.error as String), contains('Pair mismatch'));
      expect(persistedEnvelopes, isEmpty);
    });

    test('should process transaction successfully', () async {
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'de_ar',
      );

      final status = await manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');

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
        languagePairKey: 'de_ar',
      );

      final status1 = await manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');
      expect(status1.state, TransactionState.committed);
      expect(persistedEnvelopes, hasLength(1));

      // Simulate a repeated tap / retry
      final status2 = await manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');
      expect(status2.state, TransactionState.committed);
      expect(persistedEnvelopes, hasLength(1)); // No duplicate persistence
    });

    test('identical retry during in-flight write returns same pending future', () async {
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'de_ar',
      );

      persistenceDelay = Completer<void>();

      final future1 = manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');
      final future2 = manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');

      persistenceDelay!.complete();

      final status1 = await future1;
      final status2 = await future2;

      expect(status1.state, TransactionState.committed);
      expect(status2.state, TransactionState.committed);
      expect(persistedEnvelopes, hasLength(1)); // Ensures it was only written once
    });

    test('duplicate command with changed payload fails', () async {
      final timestamp = DateTime.now();
      final envelope1 = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 3,
        timestamp: timestamp,
        languagePairKey: 'de_ar',
      );

      final envelope2 = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 2, // Changed rating
        timestamp: timestamp,
        languagePairKey: 'de_ar',
      );

      final status1 = await manager.commitReview(envelope1, activeLanguagePairKey: 'de_ar');
      expect(status1.state, TransactionState.committed);

      final status2 = await manager.commitReview(envelope2, activeLanguagePairKey: 'de_ar');
      expect(status2.state, TransactionState.failed);
      expect(
        status2.error,
        'Conflicting reviewEventId payload',
      );
      expect(persistedEnvelopes, hasLength(1));
    });

    test('simulated storage failure transitions to recoverable state', () async {
      shouldFailPersistence = true;
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'de_ar',
      );

      final status = await manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');

      expect(status.state, TransactionState.recoverable);
      expect(status.error, isA<Exception>());
      expect(persistedEnvelopes, isEmpty);

      // Verify it's returned by getRecoverableTransactions
      final recoverable = manager.getRecoverableTransactions();
      expect(recoverable, hasLength(1));
      expect(recoverable.first.envelope, envelope);

      // Now fix storage and retry
      shouldFailPersistence = false;
      final retryStatus = await manager.commitReview(envelope, activeLanguagePairKey: 'de_ar');
      expect(retryStatus.state, TransactionState.committed);
      expect(persistedEnvelopes, hasLength(1));
    });
  });
}
