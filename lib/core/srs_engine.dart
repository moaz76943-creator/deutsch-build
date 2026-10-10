enum ReviewRating {
  again,
  hard,
  good,
  easy,
}

class SrsItemState {
  final int repetitions;
  final int interval;
  final double easeFactor;
  final DateTime nextReviewDate;
  final DateTime lastReviewed;

  SrsItemState({
    this.repetitions = 0,
    this.interval = 1,
    this.easeFactor = 2.5,
    DateTime? nextReviewDate,
    DateTime? lastReviewed,
  })  : nextReviewDate = nextReviewDate ?? DateTime.now(),
        lastReviewed = lastReviewed ?? DateTime.now();

  dynamic operator [](String key) {
    switch (key) {
      case 'repetitions':
        return repetitions;
      case 'interval':
        return interval;
      case 'easeFactor':
        return easeFactor;
      case 'nextReviewDate':
        return nextReviewDate;
      case 'lastReviewed':
        return lastReviewed;
      default:
        return null;
    }
  }
}

class SrsEngine {
  static Future<SrsItemState> getItemState(dynamic key) async {
    return SrsItemState(
      repetitions: 0,
      interval: 1,
      easeFactor: 2.5,
      nextReviewDate: DateTime.now().add(const Duration(days: 1)),
      lastReviewed: DateTime.now(),
    );
  }

  static Future<void> processReview([
    dynamic p1,
    dynamic p2,
    dynamic p3,
    dynamic p4,
  ]) async {}

  static Map<String, dynamic> calculateNextReview({
    required int grade,
    required int repetitions,
    required double previousEaseFactor,
    required int previousInterval,
    double morphologicalMultiplier = 1.0,
  }) {
    int nextRepetitions = repetitions;
    int nextInterval = previousInterval;
    double nextEaseFactor = previousEaseFactor;

    if (grade >= 3) {
      if (repetitions == 0) {
        nextInterval = 1;
      } else if (repetitions == 1) {
        nextInterval = 6;
      } else {
        nextInterval = (previousInterval * previousEaseFactor * morphologicalMultiplier).round();
      }
      nextRepetitions += 1;
    } else {
      nextRepetitions = 0;
      nextInterval = 1;
    }

    nextEaseFactor = previousEaseFactor + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02));
    if (nextEaseFactor < 1.3) {
      nextEaseFactor = 1.3;
    }

    return {
      'repetitions': nextRepetitions,
      'interval': nextInterval,
      'easeFactor': double.parse(nextEaseFactor.toStringAsFixed(2)),
    };
  }
}
