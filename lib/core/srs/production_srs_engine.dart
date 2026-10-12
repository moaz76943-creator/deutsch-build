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
  })  : assert(nextIntervalDays >= 0, 'nextIntervalDays cannot be negative'),
        assert(easeFactor >= 1.3, 'easeFactor must be at least 1.3'),
        assert(repetitionCount >= 0, 'repetitionCount cannot be negative');
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
  }) {
    if (currentIntervalDays < 0) throw ArgumentError('currentIntervalDays cannot be negative');
    if (currentRepetitions < 0) throw ArgumentError('currentRepetitions cannot be negative');
    if (currentEaseFactor.isNaN) throw ArgumentError('currentEaseFactor cannot be NaN');
    if (morphologicalMultiplier.isNaN || morphologicalMultiplier < 0) throw ArgumentError('morphologicalMultiplier is invalid');

    int newRepetitions = currentRepetitions;
    int newInterval = currentIntervalDays;
    double newEase = math.max(1.3, currentEaseFactor);

    switch (rating) {
      case SrsRating.hard:
        newRepetitions = 0;
        newInterval = 1;
        newEase = math.max(1.3, newEase - 0.2);
        break;
      case SrsRating.good:
        if (newRepetitions == 0) {
          newInterval = 1;
        } else if (newRepetitions == 1) {
          newInterval = 3;
        } else {
          newInterval = math.max(1, (currentIntervalDays * newEase * morphologicalMultiplier).round());
        }
        newRepetitions += 1;
        break;
      case SrsRating.easy:
        if (newRepetitions == 0) {
          newInterval = 2;
        } else if (newRepetitions == 1) {
          newInterval = 5;
        } else {
          newInterval = math.max(1, (currentIntervalDays * newEase * 1.3 * morphologicalMultiplier).round());
        }
        newRepetitions += 1;
        newEase = math.min(2.5, math.max(1.3, newEase + 0.15));
        break;
    }

    final now = currentTime ?? DateTime.now();
    final nextDate = now.add(Duration(days: math.max(1, newInterval)));

    return SrsCardReviewResult(
      nextIntervalDays: newInterval,
      easeFactor: newEase,
      repetitionCount: newRepetitions,
      nextReviewDate: nextDate,
    );
  }
}
