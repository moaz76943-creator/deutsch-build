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
  static const double maxEaseFactor = 3.0;
  static const int maxIntervalDays = 36500;
  static const int maxRepetitions = 1000000;

  /// Backwards-compatible SM-2 calculator; 0..5 rating, no I/O.
  static Sm2ReviewResult calculateNextReview({
    required int quality,
    required double currentEaseFactor,
    required int repetitions,
    required int intervalDays,
    DateTime? currentTime,
  }) {
    if (quality < 0 || quality > 5 ||
        repetitions < 0 || repetitions > maxRepetitions ||
        intervalDays < 0 || intervalDays > maxIntervalDays ||
        !currentEaseFactor.isFinite) {
      throw ArgumentError('Malformed SM-2 input state');
    }
    // Preserve the historical mapping of 0 to quality 1.
    final int q = quality.clamp(1, 5).toInt();
    final baseEase = currentEaseFactor.clamp(minEaseFactor, maxEaseFactor).toDouble();
    final proposedEase = baseEase +
        (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    final newEase = proposedEase.clamp(minEaseFactor, maxEaseFactor).toDouble();

    int newReps = repetitions;
    int newInterval = 1;
    if (q < 3) {
      newReps = 0;
    } else {
      if (repetitions == 0) {
        newInterval = 1;
      } else if (repetitions == 1) {
        newInterval = 6;
      } else {
        final proposed = intervalDays * newEase;
        if (!proposed.isFinite) throw ArgumentError('Invalid interval');
        newInterval = proposed.round().clamp(1, maxIntervalDays).toInt();
      }
      if (newReps < maxRepetitions) newReps++;
    }

    final nextDate = (currentTime ?? DateTime.now())
        .add(Duration(days: newInterval));
    return Sm2ReviewResult(
      easeFactor: newEase,
      intervalDays: newInterval,
      repetitions: newReps,
      nextReviewDate: nextDate,
    );
  }
}
