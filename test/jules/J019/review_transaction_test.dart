import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_state.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_persistence_port.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

class MockTransactionPersistencePort implements TransactionPersistencePort {
  final Map<String, TransactionState> states = {};
  final Map<String, ReviewTransactionEnvelope> envelopes = {};

  @override
  Future<TransactionState?> getTransactionState(String reviewEventId) async {
    return states[reviewEventId];
  }

  @override
  Future<ReviewTransactionEnvelope?> getTransactionEnvelope(String reviewEventId) async {
    return envelopes[reviewEventId];
  }

  @override
  Future<void> saveTransaction(ReviewTransactionEnvelope envelope, TransactionState state) async {
    envelopes[envelope.reviewEventId] = envelope;
    states[envelope.reviewEventId] = state;
  }

  @override
  Future<void> updateTransactionState(String reviewEventId, TransactionState state) async {
    states[reviewEventId] = state;
  }
}

void main() {
  group('ReviewTransactionManager', () {
    late MockTransactionPersistencePort mockPersistence;
    late ReviewTransactionManager manager;

    setUp(() {
      mockPersistence = MockTransactionPersistencePort();
      manager = ReviewTransactionManager(mockPersistence);
    });

    test('Isolation: A->B is processed independently from B->A', () async {
      final commandAB = ReviewCommand(
        reviewId: 'rev-1',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'card-1',
        facetKey: 'f-1',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      final commandBA = ReviewCommand(
        reviewId: 'rev-2',
        sourceLanguageId: 'ar',
        targetLanguageId: 'de',
        cardId: 'card-1',
        facetKey: 'f-1',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      int commitCountAB = 0;
      int commitCountBA = 0;

      await manager.processTransaction(commandAB, () async {
        commitCountAB++;
      });

      await manager.processTransaction(commandBA, () async {
        commitCountBA++;
      });

      expect(commitCountAB, 1);
      expect(commitCountBA, 1);
      expect(mockPersistence.states['rev-1'], TransactionState.committed);
      expect(mockPersistence.states['rev-2'], TransactionState.committed);
      expect(mockPersistence.envelopes['rev-1']?.languagePairKey, 'de->ar');
      expect(mockPersistence.envelopes['rev-2']?.languagePairKey, 'ar->de');
    });

    test('Idempotency: Repeated identical commands do not re-commit', () async {
      final command = ReviewCommand(
        reviewId: 'rev-3',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'card-2',
        facetKey: 'f-2',
        pairEpoch: 1,
        rating: ReviewRating.easy,
        hinted: false,
      );

      int commitCount = 0;
      final performCommit = () async {
        commitCount++;
      };

      await manager.processTransaction(command, performCommit);
      await manager.processTransaction(command, performCommit);
      await manager.processTransaction(command, performCommit);

      expect(commitCount, 1);
      expect(mockPersistence.states['rev-3'], TransactionState.committed);
    });

    test('Duplicate commands with conflicting data are rejected', () async {
      final command1 = ReviewCommand(
        reviewId: 'rev-4',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'card-3',
        facetKey: 'f-3',
        pairEpoch: 1,
        rating: ReviewRating.easy,
        hinted: false,
      );

      final command2 = ReviewCommand(
        reviewId: 'rev-4',
        sourceLanguageId: 'ar', // Conflicting pair
        targetLanguageId: 'de',
        cardId: 'card-3',
        facetKey: 'f-3',
        pairEpoch: 1,
        rating: ReviewRating.easy,
        hinted: false,
      );

      int commitCount = 0;

      await manager.processTransaction(command1, () async {
        commitCount++;
      });

      expect(
        () => manager.processTransaction(command2, () async { commitCount++; }),
        throwsA(isA<Exception>()),
      );

      expect(commitCount, 1);
    });

    test('Storage failure transitions state to recoverable', () async {
      final command = ReviewCommand(
        reviewId: 'rev-5',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'card-4',
        facetKey: 'f-4',
        pairEpoch: 1,
        rating: ReviewRating.hard,
        hinted: false,
      );

      try {
        await manager.processTransaction(command, () async {
          throw Exception('Simulated storage failure');
        });
      } catch (e) {
        // Expected
      }

      expect(mockPersistence.states['rev-5'], TransactionState.recoverable);
    });
  });
}
