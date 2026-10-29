// ignore_for_file: prefer_const_constructors
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

class ProductionSrsEngine {
  /// معالجة مراجعة البطاقة وفق خوارزمية SM-2 المعدلة رياضياً
  static SrsCardReviewResult processReview({
    required int currentIntervalDays,
    required double currentEaseFactor,
    required int currentRepetitions,
    required SrsRating rating,
    double morphologicalMultiplier = 1.0,
    DateTime? now,
  }) {
    if (currentIntervalDays < 0) throw ArgumentError('Interval cannot be negative');
    if (currentRepetitions < 0) throw ArgumentError('Repetitions cannot be negative');
    if (currentEaseFactor.isNaN) throw ArgumentError('Ease factor cannot be NaN');
    if (morphologicalMultiplier.isNaN || morphologicalMultiplier < 0) {
      throw ArgumentError('Invalid morphologicalMultiplier');
    }

    int newRepetitions = currentRepetitions;
    int newInterval = currentIntervalDays;
    double newEase = currentEaseFactor;

    switch (rating) {
      case SrsRating.hard:
        newRepetitions = 0;
        newInterval = 1;
        newEase = math.max(1.3, currentEaseFactor - 0.2);
        break;
      case SrsRating.good:
        if (newRepetitions == 0) {
          newInterval = 1;
        } else if (newRepetitions == 1) {
          newInterval = 3;
        } else {
          newInterval = math.max(1, (currentIntervalDays * currentEaseFactor * morphologicalMultiplier).round());
        }
        newRepetitions += 1;
        newEase = math.max(1.3, currentEaseFactor); // clamp if it was previously invalid
        break;
      case SrsRating.easy:
        if (newRepetitions == 0) {
          newInterval = 2;
        } else if (newRepetitions == 1) {
          newInterval = 5;
        } else {
          newInterval = math.max(1, (currentIntervalDays * currentEaseFactor * 1.3 * morphologicalMultiplier).round());
        }
        newRepetitions += 1;
        newEase = math.max(1.3, math.min(2.5, currentEaseFactor + 0.15));
        break;
    }

    final calculationTime = now ?? DateTime.now();
    final nextDate = calculationTime.add(Duration(days: math.max(1, newInterval)));

    return SrsCardReviewResult(
      nextIntervalDays: newInterval,
      easeFactor: newEase,
      repetitionCount: newRepetitions,
      nextReviewDate: nextDate,
    );
  }
}
