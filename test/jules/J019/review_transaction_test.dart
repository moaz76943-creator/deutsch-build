import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_persistence_port.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

class MockTransactionPersistencePort implements TransactionPersistencePort {
  final Map<String, ReviewCommand> commands = {};
  final Map<String, ReviewTransactionEnvelope> envelopes = {};
  int commitCount = 0;
  bool shouldFail = false;

  @override
  Future<ReviewCommitResult> commitOnce({
    required ReviewCommand command,
    required ReviewTransactionEnvelope envelope,
  }) async {
    if (shouldFail) {
      throw Exception('Simulated storage failure');
    }

    if (commands.containsKey(command.reviewId)) {
        if (!commands[command.reviewId]!.samePayloadAs(command)) {
            throw StateError('Review event ID reused with a conflicting payload');
        }
        return ReviewCommitResult.alreadyCommitted;
    }

    commands[command.reviewId] = command;
    envelopes[command.reviewId] = envelope;
    commitCount++;
    return ReviewCommitResult.committed;
  }
}

void main() {
  group('ReviewTransactionManager J019 Tests', () {
    late MockTransactionPersistencePort mockPersistence;
    late ReviewTransactionManager manager;

    setUp(() {
      mockPersistence = MockTransactionPersistencePort();
      manager = ReviewTransactionManager(mockPersistence, clock: () => DateTime.utc(2023, 1, 1));
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

      await manager.processTransaction(commandAB);
      await manager.processTransaction(commandBA);

      expect(mockPersistence.commitCount, 2);
      expect(mockPersistence.commands.length, 2);
      expect(mockPersistence.envelopes['rev-1']?.languagePairKey, 'de_ar_1.0.0');
      expect(mockPersistence.envelopes['rev-2']?.languagePairKey, 'ar_de_1.0.0');
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

      await manager.processTransaction(command1);

      expect(
        () => manager.processTransaction(command2),
        throwsA(isA<StateError>()),
      );

      expect(mockPersistence.commitCount, 1);
    });

    test('Storage failure bubbles up', () async {
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

      mockPersistence.shouldFail = true;

      expect(
        () => manager.processTransaction(command),
        throwsA(isA<Exception>()),
      );

      expect(mockPersistence.commitCount, 0);
    });

    test('Identical retry works', () async {
      final command1 = ReviewCommand(
        reviewId: 'rev-6',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'card-5',
        facetKey: 'f-5',
        pairEpoch: 1,
        rating: ReviewRating.easy,
        hinted: false,
      );

      final res1 = await manager.processTransaction(command1);
      final res2 = await manager.processTransaction(command1);

      expect(res1, ReviewCommitResult.committed);
      expect(res2, ReviewCommitResult.alreadyCommitted);
      expect(mockPersistence.commitCount, 1);
    });
  });
}
