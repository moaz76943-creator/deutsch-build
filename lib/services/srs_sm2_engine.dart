class Sm2ReviewResult {
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime nextReviewDate;

  const Sm2ReviewResult({
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.nextReviewDate,
  });
}

class SrsSm2Engine {
  static const double minEaseFactor = 1.3;
  static const int maxIntervalDays = 36500;
  static const int maxRepetitions = 1000000;

  /// Legacy SM-2 quality 0..5. Preserve second-success = 6 days.
  static Sm2ReviewResult calculateNextReview({
    required int quality,
    required double currentEaseFactor,
    required int repetitions,
    required int intervalDays,
    DateTime? currentTime,
  }) {
    if (!currentEaseFactor.isFinite ||
        currentEaseFactor <= 0 ||
        repetitions < 0 ||
        intervalDays < 0) {
      throw ArgumentError('Malformed SM-2 review inputs');
    }
    final q = quality.clamp(1, 5).toInt();
    final ease = currentEaseFactor.clamp(minEaseFactor, 3.0).toDouble();
    final newEf = (ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))
        .clamp(minEaseFactor, 3.0)
        .toDouble();

    var newReps = repetitions.clamp(0, maxRepetitions).toInt();
    var newInterval = 1;
    if (q < 3) {
      newReps = 0;
    } else {
      if (newReps == 0) {
        newInterval = 1;
      } else if (newReps == 1) {
        newInterval = 6;
      } else {
        newInterval = (intervalDays.clamp(0, maxIntervalDays) * newEf)
            .round()
            .clamp(1, maxIntervalDays)
            .toInt();
      }
      newReps = (newReps + 1).clamp(0, maxRepetitions).toInt();
    }

    return Sm2ReviewResult(
      easeFactor: newEf,
      intervalDays: newInterval,
      repetitions: newReps,
      nextReviewDate:
          (currentTime ?? DateTime.now()).add(Duration(days: newInterval)),
    );
  }
}
