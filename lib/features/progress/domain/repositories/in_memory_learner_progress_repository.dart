import '../models/card_progress.dart';
import '../models/deck_summary.dart';
import '../models/review_log.dart';
import '../models/srs_item_state.dart';
import 'i_learner_progress_repository.dart';

class InMemoryLearnerProgressRepository implements ILearnerProgressRepository {
  final Map<String, CardProgress> _progressData = {};
  final List<ReviewLog> _reviewLogs = [];

  // Expose for testing/seeding purposes if needed
  void seedCardProgress(CardProgress progress) {
    _progressData[progress.cardId] = progress;
  }

  @override
  Future<CardProgress?> getCardProgress(String cardId) async {
    return _progressData[cardId];
  }

  @override
  Future<List<CardProgress>> getDueCards({required DateTime asOf, int? limit}) async {
    final dueCards = _progressData.values.where((progress) {
      if (progress.lastReviewedAt == null) return true;
      // In a real app we'd have a 'nextReviewAt' property,
      // but for this mock, let's say if it hasn't been reviewed in the future, it's due.
      // Or simply, anything that was last reviewed before 'asOf' minus some interval.
      // For the mock, we'll just say it's due if lastReviewedAt is before asOf.
      return progress.lastReviewedAt!.isBefore(asOf);
    }).toList();

    if (limit != null && dueCards.length > limit) {
      return dueCards.take(limit).toList();
    }
    return dueCards;
  }

  @override
  Future<void> saveReview({required CardProgress updatedProgress, required ReviewLog log}) async {
    _progressData[updatedProgress.cardId] = updatedProgress;
    _reviewLogs.add(log);
  }

  @override
  Future<DeckSummary> getDeckSummary(String deckId) async {
    // For this mock, we assume all cards in _progressData belong to the deck.
    int totalCards = _progressData.length;
    int dueCount = 0;
    int masteredCount = 0;
    int learningCount = 0;

    final now = DateTime.now();

    for (final progress in _progressData.values) {
      if (progress.lastReviewedAt == null || progress.lastReviewedAt!.isBefore(now)) {
        dueCount++;
      }
      if (progress.srsItemState == SrsItemState.mastered) {
        masteredCount++;
      } else if (progress.srsItemState == SrsItemState.learning) {
        learningCount++;
      }
    }

    return DeckSummary(
      totalCards: totalCards,
      dueCount: dueCount,
      masteredCount: masteredCount,
      learningCount: learningCount,
    );
  }
}
