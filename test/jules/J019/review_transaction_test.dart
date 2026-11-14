import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_persistence_port.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

class MockTransactionPersistencePort implements TransactionPersistencePort {
  final Map<String, ReviewTransactionEnvelope> envelopes = {};
  int commitCallCount = 0;
  bool shouldThrow = false;

  @override
  Future<ReviewCommitResult> commitOnce({
    required ReviewCommand command,
    required ReviewTransactionEnvelope envelope,
  }) async {
    if (shouldThrow) {
      throw Exception('Simulated storage failure');
    }
    commitCallCount++;

    // Exact idempotent match simulation
    final existing = envelopes[envelope.reviewEventId];
    if (existing != null) {
      if (existing.learnerContentKey == envelope.learnerContentKey &&
          existing.rating == envelope.rating &&
          existing.languagePairKey == envelope.languagePairKey) {
        return ReviewCommitResult.alreadyCommitted;
      }
      throw StateError('Review event ID reused with a conflicting payload');
    }

    envelopes[envelope.reviewEventId] = envelope;
    return ReviewCommitResult.committed;
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

      final resultAB = await manager.processTransaction(commandAB);
      final resultBA = await manager.processTransaction(commandBA);

      expect(mockPersistence.commitCallCount, 2);
      expect(resultAB, ReviewCommitResult.committed);
      expect(resultBA, ReviewCommitResult.committed);

      expect(mockPersistence.envelopes['rev-1']?.languagePairKey, 'de_ar_1.0.0');
      expect(mockPersistence.envelopes['rev-2']?.languagePairKey, 'ar_de_1.0.0');
    });

    test('Idempotency: Repeated identical commands return alreadyCommitted', () async {
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

      final result1 = await manager.processTransaction(command);
      final result2 = await manager.processTransaction(command);
      final result3 = await manager.processTransaction(command);

      expect(mockPersistence.commitCallCount, 3);
      expect(result1, ReviewCommitResult.committed);
      expect(result2, ReviewCommitResult.alreadyCommitted);
      expect(result3, ReviewCommitResult.alreadyCommitted);
    });

    test('Duplicate commands with conflicting data are rejected by durable persistence', () async {
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

      final result1 = await manager.processTransaction(command1);
      expect(result1, ReviewCommitResult.committed);

      expect(
        () => manager.processTransaction(command2),
        throwsA(isA<StateError>()),
      );

      expect(mockPersistence.commitCallCount, 2);
    });

    test('Storage failure propagates correctly', () async {
      mockPersistence.shouldThrow = true;
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

      expect(
        () => manager.processTransaction(command),
        throwsA(isA<Exception>()),
      );

      expect(mockPersistence.envelopes, isEmpty);
    });

    test('Rejects malformed commands synchronously', () async {
      final malformedCommand = ReviewCommand(
        reviewId: '   ', // Invalid ID
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'card-1',
        facetKey: 'f-1',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      expect(
        () => manager.processTransaction(malformedCommand),
        throwsA(isA<ArgumentError>()),
      );

      expect(mockPersistence.commitCallCount, 0);
    });
  });
}
