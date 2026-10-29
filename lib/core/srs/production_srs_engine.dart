import 'dart:math' as math;

enum SrsRating { hard, good, easy }

class SrsCardReviewResult {
  final int nextIntervalDays;
  final double easeFactor;
  final int repetitionCount;
  final DateTime nextReviewDate;

  const SrsCardReviewResult({
    required this.nextIntervalDays,
    required this.easeFactor,
    required this.repetitionCount,
    required this.nextReviewDate,
  });
}

/// Pure bounded scheduling math. This does not persist progress or award XP.
class ProductionSrsEngine {
  static const int maxIntervalDays = 36500;
  static const int maxRepetitions = 1000000;

  static SrsCardReviewResult processReview({
    required int currentIntervalDays,
    required double currentEaseFactor,
    required int currentRepetitions,
    required SrsRating rating,
    double morphologicalMultiplier = 1.0,
    DateTime? currentTime,
  }) {
    if (currentIntervalDays < 0 || currentIntervalDays > maxIntervalDays) {
      throw ArgumentError.value(currentIntervalDays, 'currentIntervalDays');
    }
    if (currentRepetitions < 0 || currentRepetitions > maxRepetitions) {
      throw ArgumentError.value(currentRepetitions, 'currentRepetitions');
    }
    if (!currentEaseFactor.isFinite) {
      throw ArgumentError.value(currentEaseFactor, 'currentEaseFactor');
    }
    if (!morphologicalMultiplier.isFinite ||
        morphologicalMultiplier < 0.1 ||
        morphologicalMultiplier > 10.0) {
      throw ArgumentError.value(morphologicalMultiplier, 'morphologicalMultiplier');
    }

    final ease = currentEaseFactor.clamp(1.3, 2.5).toDouble();
    int repetitions = currentRepetitions;
    int interval;
    double newEase = ease;

    switch (rating) {
      case SrsRating.hard:
        repetitions = 0;
        interval = 1;
        newEase = math.max(1.3, ease - 0.2);
        break;
      case SrsRating.good:
        if (repetitions == 0) {
          interval = 1;
        } else if (repetitions == 1) {
          interval = 3;
        } else {
          interval = _boundedInterval(
            currentIntervalDays * ease * morphologicalMultiplier,
          );
        }
        repetitions = math.min(maxRepetitions, repetitions + 1);
        break;
      case SrsRating.easy:
        if (repetitions == 0) {
          interval = 2;
        } else if (repetitions == 1) {
          interval = 5;
        } else {
          interval = _boundedInterval(
            currentIntervalDays * ease * 1.3 * morphologicalMultiplier,
          );
        }
        repetitions = math.min(maxRepetitions, repetitions + 1);
        newEase = math.min(2.5, ease + 0.15);
        break;
    }

    final now = currentTime ?? DateTime.now();
    return SrsCardReviewResult(
      nextIntervalDays: interval,
      easeFactor: newEase,
      repetitionCount: repetitions,
      nextReviewDate: now.add(Duration(days: interval)),
    );
  }

  static int _boundedInterval(double days) {
    if (!days.isFinite) throw ArgumentError.value(days, 'intervalDays');
    return days.round().clamp(1, maxIntervalDays).toInt();
  }
}
