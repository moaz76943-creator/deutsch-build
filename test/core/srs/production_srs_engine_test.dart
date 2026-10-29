import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';

void main() {
  group('ProductionSrsEngine Tests', () {
    final fixedTime = DateTime(2024, 2, 29); // Leap year

    test('first review (good)', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 0,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.good,
        currentTime: fixedTime,
      );

      expect(result.nextIntervalDays, 1);
      expect(result.easeFactor, 2.5);
      expect(result.repetitionCount, 1);
      expect(result.nextReviewDate, DateTime(2024, 3, 1));
    });

    test('repeated failures (hard)', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 14,
        currentEaseFactor: 2.0,
        currentRepetitions: 3,
        rating: SrsRating.hard,
        currentTime: fixedTime,
      );

      expect(result.nextIntervalDays, 1);
      expect(result.easeFactor, 1.8);
      expect(result.repetitionCount, 0);
      expect(result.nextReviewDate, DateTime(2024, 3, 1));
    });

    test('successful recall (easy)', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 5,
        currentEaseFactor: 2.0,
        currentRepetitions: 2,
        rating: SrsRating.easy,
        currentTime: fixedTime,
      );

      // (5 * 2.0 * 1.3 * 1.0) = 13
      expect(result.nextIntervalDays, 13);
      expect(result.easeFactor, 2.15);
      expect(result.repetitionCount, 3);
      expect(result.nextReviewDate, DateTime(2024, 3, 13));
    });

    test('ease-factor boundaries (never below 1.3)', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 5,
        currentEaseFactor: 1.4,
        currentRepetitions: 2,
        rating: SrsRating.hard,
        currentTime: fixedTime,
      );

      expect(result.easeFactor, 1.3); // Clamped to 1.3
    });

    test('ease-factor boundaries (does not drop below 1.3 even if legacy input is low)', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 5,
        currentEaseFactor: 1.0,
        currentRepetitions: 2,
        rating: SrsRating.hard,
        currentTime: fixedTime,
      );

      expect(result.easeFactor, 1.3); // Clamped to 1.3
    });

    test('leap days (using injected time)', () {
      final leapTime = DateTime(2024, 2, 28);
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 0,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.good,
        currentTime: leapTime,
      );

      // Interval should be 1 day, adding 1 day to 2024-02-28 is 2024-02-29
      expect(result.nextReviewDate, DateTime(2024, 2, 29));
    });

    test('validation errors (negative intervals, NaN inputs, negative repetitions)', () {
      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: -1,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );

      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: 0,
          currentEaseFactor: double.nan,
          currentRepetitions: 0,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );

      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: 0,
          currentEaseFactor: 2.5,
          currentRepetitions: -5,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );
    });

    test('SrsCardReviewResult constructor validation', () {
      expect(
        () => SrsCardReviewResult(
          nextIntervalDays: -1,
          easeFactor: 2.5,
          repetitionCount: 1,
          nextReviewDate: DateTime.now(),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => SrsCardReviewResult(
          nextIntervalDays: 1,
          easeFactor: double.nan,
          repetitionCount: 1,
          nextReviewDate: DateTime.now(),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => SrsCardReviewResult(
          nextIntervalDays: 1,
          easeFactor: 2.5,
          repetitionCount: -1,
          nextReviewDate: DateTime.now(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
