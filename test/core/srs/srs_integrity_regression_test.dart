import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';
import 'package:deutsch_bilarabi/core/srs/spaced_repetition_engine.dart';
import 'package:deutsch_bilarabi/core/srs/leitner_box_state.dart';

void main() {
  final instant = DateTime.utc(2026, 10, 13);
  test('fixed clock gives a deterministic schedule', () {
    final a = ProductionSrsEngine.processReview(
      currentIntervalDays: 8,
      currentEaseFactor: 2.5,
      currentRepetitions: 3,
      rating: SrsRating.good,
      currentTime: instant,
    );
    final b = ProductionSrsEngine.processReview(
      currentIntervalDays: 8,
      currentEaseFactor: 2.5,
      currentRepetitions: 3,
      rating: SrsRating.good,
      currentTime: instant,
    );
    expect(a.nextIntervalDays, 20);
    expect(a.nextReviewDate, instant.add(const Duration(days: 20)));
    expect(a.nextReviewDate, b.nextReviewDate);
  });

  test('malformed, nonfinite and negative review state fails closed', () {
    for (final invalid in [double.nan, double.infinity, -1.0, 0.0]) {
      expect(
          () => ProductionSrsEngine.processReview(
                currentIntervalDays: 1,
                currentEaseFactor: invalid,
                currentRepetitions: 1,
                rating: SrsRating.good,
                currentTime: instant,
              ),
          throwsArgumentError);
    }
    expect(
        () => ProductionSrsEngine.processReview(
              currentIntervalDays: -1,
              currentEaseFactor: 2.5,
              currentRepetitions: 1,
              rating: SrsRating.good,
            ),
        throwsArgumentError);
    expect(
        () => ProductionSrsEngine.processReview(
              currentIntervalDays: 1,
              currentEaseFactor: 2.5,
              currentRepetitions: -1,
              rating: SrsRating.good,
            ),
        throwsArgumentError);
  });

  test('huge legacy values stay bounded without integer wrap', () {
    final result = ProductionSrsEngine.processReview(
      currentIntervalDays: 999999999,
      currentEaseFactor: 99,
      currentRepetitions: 999999999,
      rating: SrsRating.easy,
      morphologicalMultiplier: 99,
      currentTime: instant,
    );
    expect(result.nextIntervalDays, lessThanOrEqualTo(36500));
    expect(result.repetitionCount, lessThanOrEqualTo(1000000));
    expect(result.easeFactor, inInclusiveRange(1.3, 3.0));
  });

  test('Leitner rejects malformed inputs and preserves bounded success', () {
    const base = LeitnerCardState(
      cardId: 'card',
      currentBox: LeitnerBox.box2,
      lastReviewedEpoch: 0,
      nextReviewEpoch: 0,
      easeFactor: 2.5,
      consecutiveSuccesses: 1000000,
    );
    expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
              previousState: base,
              rating: 8,
              currentTimeMs: 1000000,
            ),
        throwsArgumentError);
    final next = SpacedRepetitionEngine.calculateNextInterval(
      previousState: base,
      rating: 3,
      currentTimeMs: 1704067200000,
    );
    expect(next.consecutiveSuccesses, 1000000);
    expect(next.lastReviewedEpoch, 1704067200000);
  });
}
