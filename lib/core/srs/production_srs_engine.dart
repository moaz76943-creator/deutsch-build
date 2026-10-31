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
    DateTime? currentTime,
    DateTime? now,
  }) {
    if (currentIntervalDays < 0) {
      throw ArgumentError('currentIntervalDays cannot be negative');
    }
    if (currentRepetitions < 0) {
      throw ArgumentError('currentRepetitions cannot be negative');
    }
    if (!currentEaseFactor.isFinite || currentEaseFactor <= 0) {
      throw ArgumentError(
        'currentEaseFactor must be a positive finite number',
      );
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
          newInterval = math.max(
              1,
              (currentIntervalDays *
                      currentEaseFactor *
                      morphologicalMultiplier)
                  .round());
        }
        newRepetitions += 1;
        break;
      case SrsRating.easy:
        if (newRepetitions == 0) {
          newInterval = 2;
        } else if (newRepetitions == 1) {
          newInterval = 5;
        } else {
          newInterval = math.max(
              1,
              (currentIntervalDays *
                      currentEaseFactor *
                      1.3 *
                      morphologicalMultiplier)
                  .round());
        }
        newRepetitions += 1;
        newEase = math.min(2.5, currentEaseFactor + 0.15);
        break;
    }

    final boundedInterval = math.min(36500, math.max(1, newInterval));
    final boundedRepetitions = math.min(1000000, newRepetitions);
    final boundedEase = newEase.clamp(1.3, 3.0).toDouble();
    final clock = currentTime ?? now ?? DateTime.now();
    final nextDate = clock.add(Duration(days: boundedInterval));

    return SrsCardReviewResult(
      nextIntervalDays: boundedInterval,
      easeFactor: boundedEase,
      repetitionCount: boundedRepetitions,
      nextReviewDate: nextDate,
    );
  }
}
