import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/progress/domain/models/card_progress.dart';

import 'package:deutsch_bilarabi/features/progress/domain/models/review_log.dart';
import 'package:deutsch_bilarabi/features/progress/domain/models/srs_item_state.dart';
import 'package:deutsch_bilarabi/features/progress/domain/repositories/in_memory_learner_progress_repository.dart';

void main() {
  late InMemoryLearnerProgressRepository repository;

  setUp(() {
    repository = InMemoryLearnerProgressRepository();
  });

  group('getCardProgress', () {
    test('returns null if card is not found', () async {
      final progress = await repository.getCardProgress('unknown_card');
      expect(progress, isNull);
    });

    test('returns card progress if found', () async {
      final cardProgress = CardProgress(
        cardId: 'card1',
        srsItemState: SrsItemState.learning,
        totalViews: 0,
        successCount: 0,
        failureCount: 0,
      );
      repository.seedCardProgress(cardProgress);

      final fetched = await repository.getCardProgress('card1');
      expect(fetched, isNotNull);
      expect(fetched?.cardId, 'card1');
    });
  });

  group('saveReview', () {
    test('saves review log and updates card progress', () async {
      final updatedProgress = CardProgress(
        cardId: 'card1',
        srsItemState: SrsItemState.review,
        totalViews: 1,
        successCount: 1,
        failureCount: 0,
        firstReviewedAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );

      final log = ReviewLog(
        id: 'log1',
        cardId: 'card1',
        rating: 3,
        reviewTimestamp: DateTime.now(),
        scheduledInterval: 1,
        durationSeconds: 15,
      );

      await repository.saveReview(updatedProgress: updatedProgress, log: log);

      final fetched = await repository.getCardProgress('card1');
      expect(fetched, equals(updatedProgress));
    });
  });

  group('getDueCards', () {
    test('returns all cards due before the specified time', () async {
      final now = DateTime.now();

      final card1 = CardProgress(
        cardId: 'card1',
        srsItemState: SrsItemState.review,
        totalViews: 1,
        successCount: 1,
        failureCount: 0,
        lastReviewedAt: now.subtract(const Duration(days: 2)), // Due
      );

      final card2 = CardProgress(
        cardId: 'card2',
        srsItemState: SrsItemState.learning,
        totalViews: 1,
        successCount: 1,
        failureCount: 0,
        lastReviewedAt: now.add(const Duration(days: 1)), // Not due
      );

      final card3 = CardProgress(
        cardId: 'card3',
        srsItemState: SrsItemState.learning,
        totalViews: 0,
        successCount: 0,
        failureCount: 0,
        lastReviewedAt: null, // Due (never reviewed)
      );

      repository.seedCardProgress(card1);
      repository.seedCardProgress(card2);
      repository.seedCardProgress(card3);

      final dueCards = await repository.getDueCards(asOf: now);

      expect(dueCards.length, 2);
      expect(dueCards.map((c) => c.cardId).contains('card1'), isTrue);
      expect(dueCards.map((c) => c.cardId).contains('card3'), isTrue);
    });

    test('respects limit when returning due cards', () async {
      final now = DateTime.now();

      repository.seedCardProgress(
        CardProgress(
          cardId: 'card1',
          srsItemState: SrsItemState.learning,
          totalViews: 0,
          successCount: 0,
          failureCount: 0,
        ),
      );

      repository.seedCardProgress(
        CardProgress(
          cardId: 'card2',
          srsItemState: SrsItemState.learning,
          totalViews: 0,
          successCount: 0,
          failureCount: 0,
        ),
      );

      final dueCards = await repository.getDueCards(asOf: now, limit: 1);
      expect(dueCards.length, 1);
    });
  });

  group('getDeckSummary', () {
    test('calculates summary correctly', () async {
      final now = DateTime.now();

      repository.seedCardProgress(
        CardProgress(
          cardId: 'card1',
          srsItemState: SrsItemState.learning,
          totalViews: 1,
          successCount: 1,
          failureCount: 0,
          lastReviewedAt: now.add(const Duration(days: 1)), // Not due
        ),
      );

      repository.seedCardProgress(
        CardProgress(
          cardId: 'card2',
          srsItemState: SrsItemState.mastered,
          totalViews: 10,
          successCount: 10,
          failureCount: 0,
          lastReviewedAt: now.subtract(const Duration(days: 1)), // Due
        ),
      );

      repository.seedCardProgress(
        CardProgress(
          cardId: 'card3',
          srsItemState: SrsItemState.review,
          totalViews: 2,
          successCount: 2,
          failureCount: 0,
          lastReviewedAt: now.subtract(const Duration(days: 1)), // Due
        ),
      );

      final summary = await repository.getDeckSummary('deck1');

      expect(summary.totalCards, 3);
      expect(summary.dueCount, 2);
      expect(summary.masteredCount, 1);
      expect(summary.learningCount, 1);
    });
  });
}
