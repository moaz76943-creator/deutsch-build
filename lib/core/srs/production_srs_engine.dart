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

/// Pure scheduling calculation. Call from the canonical worker-backed writer.
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
    if (currentIntervalDays < 0) {
      throw ArgumentError.value(currentIntervalDays, 'currentIntervalDays');
    }
    if (currentRepetitions < 0) {
      throw ArgumentError.value(currentRepetitions, 'currentRepetitions');
    }
    if (!currentEaseFactor.isFinite || currentEaseFactor <= 0) {
      throw ArgumentError.value(currentEaseFactor, 'currentEaseFactor');
    }
    if (!morphologicalMultiplier.isFinite || morphologicalMultiplier <= 0) {
      throw ArgumentError.value(morphologicalMultiplier, 'morphologicalMultiplier');
    }

    final interval = math.min(currentIntervalDays, maxIntervalDays);
    final ease = currentEaseFactor.clamp(1.3, 3.0).toDouble();
    final multiplier = morphologicalMultiplier.clamp(0.25, 4.0).toDouble();

    var nextRepetitions = math.min(currentRepetitions, maxRepetitions);
    var nextInterval = interval;
    var nextEase = ease;

    switch (rating) {
      case SrsRating.hard:
        nextRepetitions = 0;
        nextInterval = 1;
        nextEase = math.max(1.3, ease - 0.2);
        break;
      case SrsRating.good:
        if (nextRepetitions == 0) {
          nextInterval = 1;
        } else if (nextRepetitions == 1) {
          nextInterval = 3;
        } else {
          nextInterval = math.max(1, (interval * ease * multiplier).round());
        }
        nextRepetitions = math.min(nextRepetitions + 1, maxRepetitions);
        break;
      case SrsRating.easy:
        if (nextRepetitions == 0) {
          nextInterval = 2;
        } else if (nextRepetitions == 1) {
          nextInterval = 5;
        } else {
          nextInterval = math.max(1, (interval * ease * 1.3 * multiplier).round());
        }
        nextRepetitions = math.min(nextRepetitions + 1, maxRepetitions);
        nextEase = math.min(2.5, ease + 0.15);
        break;
    }

    nextInterval = math.min(nextInterval, maxIntervalDays);
    final now = currentTime ?? DateTime.now();
    return SrsCardReviewResult(
      nextIntervalDays: nextInterval,
      easeFactor: nextEase,
      repetitionCount: nextRepetitions,
      nextReviewDate: now.add(Duration(days: nextInterval)),
    );
  }
}
