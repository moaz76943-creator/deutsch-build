import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/spaced_repetition_engine.dart';
import 'package:deutsch_bilarabi/core/srs/leitner_box_state.dart';

void main() {
  group('SpacedRepetitionEngine Tests', () {
    const int fixedEpoch = 1704067200000; // 2024-01-01 00:00:00 UTC
    const int _oneDayMs = 86400000;

    test('Rating 0-1 (Hard/Again) drops to Box 1 and decreases ease', () {
      const state = LeitnerCardState(
        cardId: 'card-1',
        currentBox: LeitnerBox.box3,
        lastReviewedEpoch: fixedEpoch - _oneDayMs * 7,
        nextReviewEpoch: fixedEpoch,
        easeFactor: 2.0,
        consecutiveSuccesses: 5,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 1,
        currentTimeEpoch: fixedEpoch,
      );

      expect(nextState.currentBox, LeitnerBox.box1);
      expect(nextState.easeFactor, closeTo(1.8, 0.0001)); // 2.0 - 0.2
      expect(nextState.consecutiveSuccesses, 0);
      expect(nextState.nextReviewEpoch, fixedEpoch + _oneDayMs);
      expect(nextState.lastReviewedEpoch, fixedEpoch);
    });

    test('Rating 2 (Good) promotes box without changing ease', () {
      const state = LeitnerCardState(
        cardId: 'card-1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: fixedEpoch - _oneDayMs,
        nextReviewEpoch: fixedEpoch,
        easeFactor: 2.5,
        consecutiveSuccesses: 0,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 2,
        currentTimeEpoch: fixedEpoch,
      );

      expect(nextState.currentBox, LeitnerBox.box2); // Promoted to box 2
      expect(nextState.easeFactor, 2.5); // Unchanged
      expect(nextState.consecutiveSuccesses, 1);
      expect(nextState.nextReviewEpoch, fixedEpoch + (3 * _oneDayMs)); // box2 interval is 3
    });

    test('Rating 3 (Easy) promotes box and increases ease (up to max 3.0)', () {
      const state = LeitnerCardState(
        cardId: 'card-1',
        currentBox: LeitnerBox.box4,
        lastReviewedEpoch: fixedEpoch - _oneDayMs * 14,
        nextReviewEpoch: fixedEpoch,
        easeFactor: 2.9,
        consecutiveSuccesses: 3,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 3,
        currentTimeEpoch: fixedEpoch,
      );

      expect(nextState.currentBox, LeitnerBox.box5);
      expect(nextState.easeFactor, 3.0); // 2.9 + 0.15 clamped to 3.0
      expect(nextState.consecutiveSuccesses, 4);
      expect(nextState.nextReviewEpoch, fixedEpoch + (30 * _oneDayMs)); // box5 interval is 30
    });

    test('Rejects invalid rating', () {
      const state = LeitnerCardState(
        cardId: 'card-1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: fixedEpoch,
        nextReviewEpoch: fixedEpoch,
      );

      expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
          previousState: state,
          rating: -1,
        ),
        throwsArgumentError,
      );

      expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
          previousState: state,
          rating: 4,
        ),
        throwsArgumentError,
      );
    });
  });
}
