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
  static const int maxIntervalDays = 36500;
  static const int maxRepetitions = 1000000;

  static Future<SrsItemState> getItemState(dynamic key) async {
    return SrsItemState(
      repetitions: 0,
      interval: 1,
      easeFactor: 2.5,
      nextReviewDate: DateTime.now().add(const Duration(days: 1)),
      lastReviewed: DateTime.now(),
    );
  }

  /// Legacy compatibility placeholder; NOT a durable progress writer.
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
    if (grade < 0 ||
        grade > 5 ||
        repetitions < 0 ||
        previousInterval < 0 ||
        !previousEaseFactor.isFinite ||
        previousEaseFactor <= 0 ||
        !morphologicalMultiplier.isFinite ||
        morphologicalMultiplier <= 0) {
      throw ArgumentError('Malformed legacy SRS review inputs');
    }
    var nextRepetitions = repetitions.clamp(0, maxRepetitions).toInt();
    var nextInterval = previousInterval.clamp(0, maxIntervalDays).toInt();
    final ease = previousEaseFactor.clamp(1.3, 3.0).toDouble();
    final multiplier = morphologicalMultiplier.clamp(0.25, 4.0).toDouble();

    if (grade >= 3) {
      if (nextRepetitions == 0) {
        nextInterval = 1;
      } else if (nextRepetitions == 1) {
        nextInterval = 6; // Stable legacy policy; no unverified 1.05 change.
      } else {
        nextInterval = (nextInterval * ease * multiplier)
            .round()
            .clamp(1, maxIntervalDays)
            .toInt();
      }
      nextRepetitions = (nextRepetitions + 1).clamp(0, maxRepetitions).toInt();
    } else {
      nextRepetitions = 0;
      nextInterval = 1;
    }

    final nextEaseFactor =
        (ease + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02)))
            .clamp(1.3, 3.0)
            .toDouble();
    return {
      'repetitions': nextRepetitions,
      'interval': nextInterval,
      'easeFactor': double.parse(nextEaseFactor.toStringAsFixed(2)),
    };
  }
}
