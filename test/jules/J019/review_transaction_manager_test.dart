import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_state.dart';

void main() {
  group('ReviewTransactionManager', () {
    late ReviewTransactionManager manager;
    late List<ReviewTransactionEnvelope> persistedEnvelopes;
    late bool shouldFailPersistence;

    setUp(() {
      persistedEnvelopes = [];
      shouldFailPersistence = false;
      manager = ReviewTransactionManager(
        persistenceHandler: (envelope) async {
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

      final state = await manager.processTransaction(envelope, 'en-ar');

      expect(state, isA<TransactionStateFailed>());
      expect((state as TransactionStateFailed).reason, 'Language pair mismatch');
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

      final state = await manager.processTransaction(envelope, 'de-ar');

      expect(state, isA<TransactionStateCommitted>());
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

      final state1 = await manager.processTransaction(envelope, 'de-ar');
      expect(state1, isA<TransactionStateCommitted>());
      expect(persistedEnvelopes, hasLength(1));

      // Simulate a repeated tap / retry
      final state2 = await manager.processTransaction(envelope, 'de-ar');
      expect(state2, isA<TransactionStateCommitted>());
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
        rating: 4, // Changed rating
        timestamp: timestamp,
        languagePairKey: 'de-ar',
      );

      final state1 = await manager.processTransaction(envelope1, 'de-ar');
      expect(state1, isA<TransactionStateCommitted>());

      final state2 = await manager.processTransaction(envelope2, 'de-ar');
      expect(state2, isA<TransactionStateFailed>());
      expect(
        (state2 as TransactionStateFailed).reason,
        'Duplicate review ID with different payload',
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
        languagePairKey: 'de-ar',
      );

      final state = await manager.processTransaction(envelope, 'de-ar');

      expect(state, isA<TransactionStateRecoverable>());
      expect((state as TransactionStateRecoverable).error, isA<Exception>());
      expect(persistedEnvelopes, isEmpty);

      // Now fix storage and retry
      shouldFailPersistence = false;
      final retryState = await manager.processTransaction(envelope, 'de-ar');
      expect(retryState, isA<TransactionStateCommitted>());
      expect(persistedEnvelopes, hasLength(1));
    });

    test('restoration of session history preserves committed state', () async {
      final envelope = ReviewTransactionEnvelope(
        reviewEventId: 'event1',
        learnerContentKey: 'content1',
        rating: 3,
        timestamp: DateTime.now(),
        languagePairKey: 'de-ar',
      );

      manager.restoreSession([envelope]);

      // Retry should immediately return committed without calling persistence
      final state = await manager.processTransaction(envelope, 'de-ar');

      expect(state, isA<TransactionStateCommitted>());
      expect(persistedEnvelopes, isEmpty); // Already committed from restoration
    });
  });
}
