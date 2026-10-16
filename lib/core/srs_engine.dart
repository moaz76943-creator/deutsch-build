enum ReviewRating { again, hard, good, easy }

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
  }) : nextReviewDate = nextReviewDate ?? DateTime.now(),
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

/// Legacy compatibility math. State persistence belongs to the atomic
/// scheduler/database owner; never acknowledge a durable write from here.
class SrsEngine {
  static const int maxIntervalDays = 36500;
  static const int maxRepetitions = 1000000;

  static Future<SrsItemState> getItemState(dynamic key) async {
    return SrsItemState(
      repetitions: 0, interval: 1, easeFactor: 2.5,
      nextReviewDate: DateTime.now().add(const Duration(days: 1)),
      lastReviewed: DateTime.now(),
    );
  }

  /// This historical compatibility entry point is not a persistence layer.
  static Future<void> processReview([
    dynamic p1, dynamic p2, dynamic p3, dynamic p4,
  ]) async {}

  static Map<String, dynamic> calculateNextReview({
    required int grade,
    required int repetitions,
    required double previousEaseFactor,
    required int previousInterval,
    double morphologicalMultiplier = 1.0,
  }) {
    if (grade < 0 || grade > 5 ||
        repetitions < 0 || repetitions > maxRepetitions ||
        previousInterval < 0 || previousInterval > maxIntervalDays ||
        !previousEaseFactor.isFinite ||
        !morphologicalMultiplier.isFinite ||
        morphologicalMultiplier < 0.1 ||
        morphologicalMultiplier > 10) {
      throw ArgumentError('Malformed legacy review inputs');
    }
    final ease = previousEaseFactor.clamp(1.3, 3.0).toDouble();
    int nextRepetitions = repetitions;
    int nextInterval = 1;

    if (grade >= 3) {
      if (repetitions == 0) {
        nextInterval = 1;
      } else if (repetitions == 1) {
        // Preserve existing schedules: do not apply Jules' speculative 4 days.
        nextInterval = 6;
      } else {
        final proposed = previousInterval * ease * morphologicalMultiplier;
        if (!proposed.isFinite) throw ArgumentError('Unbounded interval');
        nextInterval = proposed.round().clamp(1, maxIntervalDays).toInt();
      }
      if (nextRepetitions < maxRepetitions) nextRepetitions++;
    } else {
      nextRepetitions = 0;
      nextInterval = 1;
    }

    final rawEase = ease +
        (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02));
    final nextEase = rawEase.clamp(1.3, 3.0).toDouble();
    return {
      'repetitions': nextRepetitions,
      'interval': nextInterval,
      'easeFactor': double.parse(nextEase.toStringAsFixed(2)),
    };
  }
}
