import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';

void main() {
  group('ProductionSrsEngine SM-2 Tests', () {
    final fixedTime = DateTime(2024, 1, 1, 12, 0, 0); // Non-leap year for baseline
    final leapYearTime = DateTime(2024, 2, 28, 12, 0, 0); // Leap year handling

    test('Initial review - Good rating calculates next interval correctly', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 0,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.good,
        currentTime: fixedTime,
      );

      expect(result.nextIntervalDays, 1);
      expect(result.repetitionCount, 1);
      expect(result.easeFactor, 2.5); // Ease shouldn't change for Good
      expect(result.nextReviewDate, fixedTime.add(const Duration(days: 1)));
    });

    test('Initial review - Easy rating calculates next interval correctly', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 0,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.easy,
        currentTime: fixedTime,
      );

      expect(result.nextIntervalDays, 2);
      expect(result.repetitionCount, 1);
      expect(result.easeFactor, 2.5); // Clamped at 2.5 max
      expect(result.nextReviewDate, fixedTime.add(const Duration(days: 2)));
    });

    test('Repeated failures decrease ease but maintain minimum of 1.3', () {
      var ease = 1.6;

      // First failure
      var result = ProductionSrsEngine.processReview(
        currentIntervalDays: 3,
        currentEaseFactor: ease,
        currentRepetitions: 2,
        rating: SrsRating.hard,
        currentTime: fixedTime,
      );

      expect(result.nextIntervalDays, 1);
      expect(result.repetitionCount, 0);
      expect(result.easeFactor, closeTo(1.4, 0.0001));

      // Second failure
      result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: result.easeFactor,
        currentRepetitions: 0,
        rating: SrsRating.hard,
        currentTime: fixedTime,
      );

      // Minimum is 1.3
      expect(result.easeFactor, 1.3);
      expect(result.nextIntervalDays, 1);
      expect(result.repetitionCount, 0);
    });

    test('Successful recall increases ease and interval correctly', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 10,
        currentEaseFactor: 2.0,
        currentRepetitions: 3,
        rating: SrsRating.good,
        currentTime: fixedTime,
      );

      expect(result.nextIntervalDays, 20); // 10 * 2.0
      expect(result.repetitionCount, 4);
      expect(result.easeFactor, 2.0);
    });

    test('Ease factor boundaries (clamped to 1.3 minimum and 2.5 maximum)', () {
      // Testing max boundary (Easy adds 0.15)
      var maxResult = ProductionSrsEngine.processReview(
        currentIntervalDays: 10,
        currentEaseFactor: 2.4,
        currentRepetitions: 3,
        rating: SrsRating.easy,
        currentTime: fixedTime,
      );
      expect(maxResult.easeFactor, 2.5);

      // Testing min boundary handled gracefully if given invalid < 1.3
      var minResult = ProductionSrsEngine.processReview(
        currentIntervalDays: 10,
        currentEaseFactor: 1.0, // Invalid initially, engine should fix it
        currentRepetitions: 3,
        rating: SrsRating.hard,
        currentTime: fixedTime,
      );
      expect(minResult.easeFactor, 1.3); // Fixed to 1.3, minus 0.2, floored at 1.3
    });

    test('Leap year handling for due dates', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 2.5,
        currentRepetitions: 1,
        rating: SrsRating.good, // Rep=1 gives interval=3
        currentTime: leapYearTime,
      );

      expect(result.nextIntervalDays, 3);
      expect(result.nextReviewDate, DateTime(2024, 3, 2, 12, 0, 0)); // Leap year adds Feb 29
    });

    test('Rejection of invalid values and NaN', () {
      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: -1,
          currentEaseFactor: 2.5,
          currentRepetitions: 1,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );

      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: 1,
          currentEaseFactor: 2.5,
          currentRepetitions: -1,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );

      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: 1,
          currentEaseFactor: double.nan,
          currentRepetitions: 1,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );
    });
  });
}
