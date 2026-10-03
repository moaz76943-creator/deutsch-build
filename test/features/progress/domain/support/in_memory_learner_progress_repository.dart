enum SrsItemState { learning, review, mastered }

class CardProgress {
  const CardProgress({
    required this.cardId,
    required this.srsItemState,
    required this.totalViews,
    required this.successCount,
    required this.failureCount,
    this.firstReviewedAt,
    this.lastReviewedAt,
  });

  final String cardId;
  final SrsItemState srsItemState;
  final int totalViews;
  final int successCount;
  final int failureCount;
  final DateTime? firstReviewedAt;
  final DateTime? lastReviewedAt;

  @override
  bool operator ==(Object other) =>
      other is CardProgress &&
      other.cardId == cardId &&
      other.srsItemState == srsItemState &&
      other.totalViews == totalViews &&
      other.successCount == successCount &&
      other.failureCount == failureCount &&
      other.firstReviewedAt == firstReviewedAt &&
      other.lastReviewedAt == lastReviewedAt;

  @override
  int get hashCode => Object.hash(
    cardId,
    srsItemState,
    totalViews,
    successCount,
    failureCount,
    firstReviewedAt,
    lastReviewedAt,
  );
}

class ReviewLog {
  const ReviewLog({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.reviewTimestamp,
    required this.scheduledInterval,
    required this.durationSeconds,
  });

  final String id;
  final String cardId;
  final int rating;
  final DateTime reviewTimestamp;
  final int scheduledInterval;
  final int durationSeconds;
}

class DeckSummary {
  const DeckSummary({
    required this.totalCards,
    required this.dueCount,
    required this.masteredCount,
    required this.learningCount,
  });

  final int totalCards;
  final int dueCount;
  final int masteredCount;
  final int learningCount;
}

class InMemoryLearnerProgressRepository {
  final Map<String, CardProgress> _progressData = <String, CardProgress>{};
  final List<ReviewLog> _reviewLogs = <ReviewLog>[];

  void seedCardProgress(CardProgress progress) {
    _progressData[progress.cardId] = progress;
  }

  Future<CardProgress?> getCardProgress(String cardId) async =>
      _progressData[cardId];

  Future<List<CardProgress>> getDueCards({
    required DateTime asOf,
    int? limit,
  }) async {
    final dueCards = _progressData.values
        .where(
          (progress) =>
              progress.lastReviewedAt == null ||
              progress.lastReviewedAt!.isBefore(asOf),
        )
        .toList(growable: false);
    return limit != null && dueCards.length > limit
        ? dueCards.take(limit).toList(growable: false)
        : dueCards;
  }

  Future<void> saveReview({
    required CardProgress updatedProgress,
    required ReviewLog log,
  }) async {
    _progressData[updatedProgress.cardId] = updatedProgress;
    _reviewLogs.add(log);
  }

  Future<DeckSummary> getDeckSummary(String deckId) async {
    var dueCount = 0;
    var masteredCount = 0;
    var learningCount = 0;
    final now = DateTime.now();

    for (final progress in _progressData.values) {
      if (progress.lastReviewedAt == null ||
          progress.lastReviewedAt!.isBefore(now)) {
        dueCount++;
      }
      if (progress.srsItemState == SrsItemState.mastered) {
        masteredCount++;
      } else if (progress.srsItemState == SrsItemState.learning) {
        learningCount++;
      }
    }

    return DeckSummary(
      totalCards: _progressData.length,
      dueCount: dueCount,
      masteredCount: masteredCount,
      learningCount: learningCount,
    );
  }
}
