
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
<<<<<<< HEAD
  static const int maxIntervalDays = 36500;
  static const int maxRepetitions = 1000000;

  /// Legacy SM-2 quality 0..5. Preserve second-success = 6 days.
=======

  /// q: تقييم المستخدم من 1 إلى 4 (أو 0 إلى 5)
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
  static Sm2ReviewResult calculateNextReview({
    required int quality,
    required double currentEaseFactor,
    required int repetitions,
    required int intervalDays,
  }) {
<<<<<<< HEAD
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
=======
    final int q = quality.clamp(1, 5);
    double newEf = currentEaseFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (newEf < minEaseFactor) newEf = minEaseFactor;

    int newReps = repetitions;
    int newInterval = 1;

>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    if (q < 3) {
      newReps = 0;
      newInterval = 1;
    } else {
      if (newReps == 0) {
        newInterval = 1;
      } else if (newReps == 1) {
        newInterval = 6;
      } else {
<<<<<<< HEAD
        newInterval = (intervalDays.clamp(0, maxIntervalDays) * newEf)
            .round()
            .clamp(1, maxIntervalDays)
            .toInt();
      }
      newReps = (newReps + 1).clamp(0, maxRepetitions).toInt();
    }

=======
        newInterval = (intervalDays * newEf).round();
      }
      newReps += 1;
    }

    final DateTime nextDate = DateTime.now().add(Duration(days: newInterval));
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    return Sm2ReviewResult(
      easeFactor = newEf,
      intervalDays = newInterval,
      repetitions = newReps,
      nextReviewDate =
          (currentTime ?? DateTime.now()).add(Duration(days: newInterval)),
    );
  }
}
