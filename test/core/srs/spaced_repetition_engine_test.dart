import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/spaced_repetition_engine.dart';
import 'package:deutsch_bilarabi/core/srs/leitner_box_state.dart';

void main() {
  group('SpacedRepetitionEngine Tests', () {
    final fixedTime = DateTime(2024, 2, 29); // Leap year

    test('calculateNextInterval - correct box progression', () {
      final initialState = LeitnerCardState(
        cardId: 'card_1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
        easeFactor: 2.5,
        consecutiveSuccesses: 0,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: initialState,
        rating: 3, // easy
        currentTime: fixedTime,
      );

      expect(nextState.currentBox, LeitnerBox.box2);
      expect(nextState.consecutiveSuccesses, 1);
      expect(nextState.easeFactor, 2.65);
      expect(nextState.nextReviewEpoch, fixedTime.millisecondsSinceEpoch + (3 * 86400000));
    });

    test('calculateNextInterval - rating 1 or 0 resets box', () {
      final initialState = LeitnerCardState(
        cardId: 'card_1',
        currentBox: LeitnerBox.box3,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
        easeFactor: 2.5,
        consecutiveSuccesses: 2,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: initialState,
        rating: 1, // hard
        currentTime: fixedTime,
      );

      expect(nextState.currentBox, LeitnerBox.box1);
      expect(nextState.consecutiveSuccesses, 0);
      expect(nextState.easeFactor, 2.3);
      expect(nextState.nextReviewEpoch, fixedTime.millisecondsSinceEpoch + (1 * 86400000));
    });

    test('calculateNextInterval - minimum ease factor boundary 1.3', () {
      final initialState = LeitnerCardState(
        cardId: 'card_1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
        easeFactor: 1.4,
        consecutiveSuccesses: 0,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: initialState,
        rating: 1, // hard -> reduces ease by 0.2
        currentTime: fixedTime,
      );

      expect(nextState.easeFactor, 1.3); // Clamped to 1.3
    });

    test('calculateNextInterval - rating validation', () {
      final initialState = LeitnerCardState(
        cardId: 'card_1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
      );

      expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
          previousState: initialState,
          rating: -1,
        ),
        throwsArgumentError,
      );

      expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
          previousState: initialState,
          rating: 6,
        ),
        throwsArgumentError,
      );
    });

    test('LeitnerCardState constructor validation', () {
      expect(
        () => LeitnerCardState(
          cardId: 'card_1',
          currentBox: LeitnerBox.box1,
          lastReviewedEpoch: 0,
          nextReviewEpoch: 0,
          easeFactor: double.nan,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => LeitnerCardState(
          cardId: 'card_1',
          currentBox: LeitnerBox.box1,
          lastReviewedEpoch: 0,
          nextReviewEpoch: 0,
          consecutiveSuccesses: -1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
