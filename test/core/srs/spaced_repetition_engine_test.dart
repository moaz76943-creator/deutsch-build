import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/spaced_repetition_engine.dart';
import 'package:deutsch_bilarabi/core/srs/leitner_box_state.dart';

void main() {
  group('SpacedRepetitionEngine', () {
    test('rejects rating outside 0-3 range', () {
      const state = LeitnerCardState(
        cardId: '1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
      );

      expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
          previousState: state,
          rating: -1,
        ),
        throwsA(isA<Error>()),
      );

      expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
          previousState: state,
          rating: 4,
        ),
        throwsA(isA<Error>()),
      );
    });

    test('rejects NaN easeFactor in previousState', () {
      expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
          previousState: LeitnerCardState(
            cardId: '1',
            currentBox: LeitnerBox.box1,
            lastReviewedEpoch: 0,
            nextReviewEpoch: 0,
            easeFactor: double.nan,
          ),
          rating: 2,
        ),
        throwsA(isA<Error>()),
      );
    });

    test('prevents duplicate review processing (debounce)', () {
      final nowMs = DateTime(2023, 1, 1).millisecondsSinceEpoch;
      final state = LeitnerCardState(
        cardId: '1',
        currentBox: LeitnerBox.box2,
        lastReviewedEpoch: nowMs,
        nextReviewEpoch: nowMs + 86400000,
        easeFactor: 2.5,
        consecutiveSuccesses: 1,
      );

      // Try processing again immediately
      final newState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 3,
        currentTimeMs: nowMs + 30000, // +30 seconds
      );

      // State should remain unchanged
      expect(newState.currentBox, state.currentBox);
      expect(newState.lastReviewedEpoch, state.lastReviewedEpoch);
    });

    test('processes failure (rating 0-1) correctly', () {
      final nowMs = DateTime(2023, 1, 1).millisecondsSinceEpoch;
      final state = LeitnerCardState(
        cardId: '1',
        currentBox: LeitnerBox.box3,
        lastReviewedEpoch: nowMs - 100000, // Passed debounce
        nextReviewEpoch: nowMs,
        easeFactor: 2.5,
        consecutiveSuccesses: 2,
      );

      final newState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 1,
        currentTimeMs: nowMs,
      );

      expect(newState.currentBox, LeitnerBox.box1);
      expect(newState.consecutiveSuccesses, 0);
      expect(newState.easeFactor, 2.3); // 2.5 - 0.2
      expect(newState.lastReviewedEpoch, nowMs);
      expect(newState.nextReviewEpoch, nowMs + 86400000); // 1 day
    });

    test('processes success (rating 2-3) correctly', () {
      final nowMs = DateTime(2023, 1, 1).millisecondsSinceEpoch;
      final state = LeitnerCardState(
        cardId: '1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: nowMs - 100000,
        nextReviewEpoch: nowMs,
        easeFactor: 2.5,
        consecutiveSuccesses: 0,
      );

      final newState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 2,
        currentTimeMs: nowMs,
      );

      expect(newState.currentBox, LeitnerBox.box2); // Moved to box 2
      expect(newState.consecutiveSuccesses, 1);
      expect(newState.easeFactor, 2.5); // Remains 2.5 since rating was not 3
      expect(newState.nextReviewEpoch, nowMs + (3 * 86400000)); // 3 days
    });

    test('ease factor bounds maintained', () {
      final nowMs = DateTime(2023, 1, 1).millisecondsSinceEpoch;
      final state = LeitnerCardState(
        cardId: '1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: nowMs - 100000,
        nextReviewEpoch: nowMs,
        easeFactor: 3.0,
        consecutiveSuccesses: 0,
      );

      final newState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 3,
        currentTimeMs: nowMs,
      );

      // Max is 3.0, so 3.0 + 0.15 should clamp to 3.0
      expect(newState.easeFactor, 3.0);
    });

    test('legacy persisted review results are processed correctly', () {
      const state = LeitnerCardState(
        cardId: 'legacy-1',
        currentBox: LeitnerBox.box5,
        lastReviewedEpoch: 1600000000000,
        nextReviewEpoch: 1600000000000,
        easeFactor: 2.1,
        consecutiveSuccesses: 10,
      );

      final newState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 3,
        currentTimeMs: 1610000000000,
      );

      // Should stay in box5 (clamped) but update last/next review epochs and successes
      expect(newState.currentBox, LeitnerBox.box5);
      expect(newState.consecutiveSuccesses, 11);
      expect(newState.easeFactor, 2.25);
    });
  });
}
