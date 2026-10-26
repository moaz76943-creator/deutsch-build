import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';
import 'package:deutsch_bilarabi/core/srs/spaced_repetition_engine.dart';
import 'package:deutsch_bilarabi/core/srs/leitner_box_state.dart';

void main() {
  test('legacy second success still follows deterministic schedule', () {
    final result = ProductionSrsEngine.processReview(
      rating: SrsRating.good,
      currentRepetitions: 1,
      currentEaseFactor: 2.5,
      currentIntervalDays: 1,
    );
    expect(result.nextIntervalDays, 3);
  });

  test('legacy SM-2 accepts an injected deterministic clock', () {
    final fixed = DateTime.utc(2026, 10, 13);
    final result = ProductionSrsEngine.processReview(
      rating: SrsRating.good,
      currentEaseFactor: 2.5,
      currentRepetitions: 1,
      currentIntervalDays: 1,
      currentTime: fixed,
    );
    expect(result.nextIntervalDays, 3);
    expect(result.nextReviewDate, fixed.add(const Duration(days: 3)));
  });

  test('nonfinite, negative legacy inputs fail closed', () {
    expect(
        () => ProductionSrsEngine.processReview(
              rating: SrsRating.good,
              currentRepetitions: -1,
              currentEaseFactor: 2.5,
              currentIntervalDays: 1,
            ),
        throwsArgumentError);
    expect(
        () => ProductionSrsEngine.processReview(
              rating: SrsRating.easy,
              currentRepetitions: 2,
              currentEaseFactor: double.nan,
              currentIntervalDays: 1,
            ),
        throwsArgumentError);
    expect(
        () => ProductionSrsEngine.processReview(
              rating: SrsRating.easy,
              currentEaseFactor: double.infinity,
              currentRepetitions: 1,
              currentIntervalDays: 1,
            ),
        throwsArgumentError);
  });

  test('legacy counters and scheduled intervals saturate safely', () {
    final result = ProductionSrsEngine.processReview(
      rating: SrsRating.easy,
      currentRepetitions: 999999999,
      currentEaseFactor: 99.0,
      currentIntervalDays: 999999999,
      morphologicalMultiplier: 99.0,
    );
    expect(result.repetitionCount, lessThanOrEqualTo(1000000));
    expect(result.nextIntervalDays, lessThanOrEqualTo(36500));
  });
}
