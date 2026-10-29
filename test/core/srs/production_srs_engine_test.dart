import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';

void main() {
  group('ProductionSrsEngine', () {
    test('rejects negative currentIntervalDays', () {
      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: -1,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );
    });

    test('rejects negative currentRepetitions', () {
      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: 1,
          currentEaseFactor: 2.5,
          currentRepetitions: -1,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );
    });

    test('rejects NaN currentEaseFactor', () {
      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: 1,
          currentEaseFactor: double.nan,
          currentRepetitions: 0,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );
    });

    test('ease factor does not fall below 1.3', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 1.4,
        currentRepetitions: 1,
        rating: SrsRating.hard,
        currentTime: DateTime(2023, 1, 1),
      );

      expect(result.easeFactor, 1.3); // 1.4 - 0.2 = 1.2, max(1.3, 1.2) = 1.3
    });

    test('calculates reproducible nextReviewDate (injected time)', () {
      final currentTime = DateTime(2023, 1, 1); // Non-leap year
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 2.5,
        currentRepetitions: 1,
        rating: SrsRating.good,
        currentTime: currentTime,
      );

      expect(result.nextIntervalDays, 3);
      expect(result.nextReviewDate, DateTime(2023, 1, 4));
    });

    test('calculates leap day accurately', () {
      final currentTime = DateTime(2024, 2, 28); // Leap year
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.easy,
        currentTime: currentTime,
      );

      expect(result.nextIntervalDays, 2);
      expect(result.nextReviewDate, DateTime(2024, 3, 1)); // 28 + 2 days in leap year is March 1st
    });

    test('standard recall success progression (good)', () {
      final result0 = ProductionSrsEngine.processReview(
        currentIntervalDays: 0,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.good,
        currentTime: DateTime(2023, 1, 1),
      );
      expect(result0.nextIntervalDays, 1);
      expect(result0.repetitionCount, 1);

      final result1 = ProductionSrsEngine.processReview(
        currentIntervalDays: result0.nextIntervalDays,
        currentEaseFactor: result0.easeFactor,
        currentRepetitions: result0.repetitionCount,
        rating: SrsRating.good,
        currentTime: DateTime(2023, 1, 2),
      );
      expect(result1.nextIntervalDays, 3);
      expect(result1.repetitionCount, 2);
    });

    test('repeated failure (hard)', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 5,
        currentEaseFactor: 2.5,
        currentRepetitions: 2,
        rating: SrsRating.hard,
        currentTime: DateTime(2023, 1, 1),
      );

      expect(result.nextIntervalDays, 1);
      expect(result.repetitionCount, 0);
      expect(result.easeFactor, 2.3);
    });
  });
}
