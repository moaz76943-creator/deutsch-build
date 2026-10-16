
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

  /// q: تقييم المستخدم من 1 إلى 4 (أو 0 إلى 5)
  static Sm2ReviewResult calculateNextReview({
    required int quality,
    required double currentEaseFactor,
    required int repetitions,
    required int intervalDays,
  }) {
    final int q = quality.clamp(1, 5);
    double newEf = currentEaseFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (newEf < minEaseFactor) newEf = minEaseFactor;

    int newReps = repetitions;
    int newInterval = 1;

    if (q < 3) {
      newReps = 0;
      newInterval = 1;
    } else {
      if (repetitions == 0) {
        newInterval = 1;
      } else if (repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (intervalDays * newEf).round();
      }
      newReps += 1;
    }

    final DateTime nextDate = DateTime.now().add(Duration(days: newInterval));
    return Sm2ReviewResult(
      easeFactor: newEf,
      intervalDays: newInterval,
      repetitions: newReps,
      nextReviewDate: nextDate,
    );
  }
}
