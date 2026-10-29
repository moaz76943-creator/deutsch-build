import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';
import 'package:deutsch_bilarabi/core/srs/spaced_repetition_engine.dart';
import 'package:deutsch_bilarabi/core/srs/leitner_box_state.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

class MockReviewCommandPort implements ReviewCommandPort {
  final List<ReviewCommand> commands = [];
  @override
  Future<void> submit(ReviewCommand command) async {
    commands.add(command);
  }
}

void main() {
  group('ProductionSrsEngine (SM-2)', () {
    final DateTime baseTime = DateTime(2024, 1, 1);

    test('First review - Again rating', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 0,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.again,
        currentTime: baseTime,
      );

      expect(result.nextIntervalDays, 1);
      expect(result.repetitionCount, 0);
      expect(result.easeFactor, 2.3);
      expect(result.nextReviewDate, baseTime.add(const Duration(days: 1)));
    });

    test('Successful recall - Good rating (first review)', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 0,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.good,
        currentTime: baseTime,
      );

      expect(result.nextIntervalDays, 1);
      expect(result.repetitionCount, 1);
      expect(result.easeFactor, 2.5);
    });

    test('Successful recall - Easy rating (first review)', () {
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 0,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.easy,
        currentTime: baseTime,
      );

      expect(result.nextIntervalDays, 2);
      expect(result.repetitionCount, 1);
      expect(result.easeFactor, 2.5); // Min(2.5, 2.5+0.15) -> 2.5
    });

    test('Repeated failures decrease ease factor, with hard minimum of 1.3', () {
      final result1 = ProductionSrsEngine.processReview(
        currentIntervalDays: 5,
        currentEaseFactor: 1.4,
        currentRepetitions: 2,
        rating: SrsRating.hard,
        currentTime: baseTime,
      );
      expect(result1.easeFactor, 1.3);

      final result2 = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 1.3,
        currentRepetitions: 0,
        rating: SrsRating.again,
        currentTime: baseTime,
      );
      expect(result2.easeFactor, 1.3);
    });

    test('Leap day calculation', () {
      final leapTime = DateTime(2024, 2, 28);
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 2.5,
        currentRepetitions: 1,
        rating: SrsRating.good,
        currentTime: leapTime,
      );

      expect(result.nextIntervalDays, 3);
      // Feb 28 + 3 days -> March 2 (2024 is a leap year)
      expect(result.nextReviewDate, DateTime(2024, 3, 2));
    });

    test('Rejects invalid input', () {
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
          currentIntervalDays: 1,
          currentEaseFactor: double.nan,
          currentRepetitions: 0,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );

      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: 1,
          currentEaseFactor: 2.5,
          currentRepetitions: -5,
          rating: SrsRating.good,
        ),
        throwsArgumentError,
      );
    });
  });

  group('SpacedRepetitionEngine (Leitner/SM-2 Hybrid)', () {
    final DateTime baseTime = DateTime(2024, 1, 1);

    test('Successful review moves to next box', () {
      final state = LeitnerCardState(
        cardId: 'test1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 3,
        currentTime: baseTime,
      );

      expect(nextState.currentBox, LeitnerBox.box2);
      expect(nextState.consecutiveSuccesses, 1);
      expect(nextState.nextReviewEpoch, baseTime.add(const Duration(days: 3)).millisecondsSinceEpoch);
      expect(nextState.easeFactor, 2.65); // 2.5 + 0.15 (clamped if needed, but not here)
    });

    test('Failure resets to box 1 and drops ease factor', () {
      final state = LeitnerCardState(
        cardId: 'test1',
        currentBox: LeitnerBox.box3,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
        consecutiveSuccesses: 2,
        easeFactor: 2.5,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 1, // failure
        currentTime: baseTime,
      );

      expect(nextState.currentBox, LeitnerBox.box1);
      expect(nextState.consecutiveSuccesses, 0);
      expect(nextState.easeFactor, 2.3);
      expect(nextState.nextReviewEpoch, baseTime.add(const Duration(days: 1)).millisecondsSinceEpoch);
    });

    test('Ease factor clamped at 1.3 minimum', () {
      final state = LeitnerCardState(
        cardId: 'test1',
        currentBox: LeitnerBox.box2,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
        consecutiveSuccesses: 1,
        easeFactor: 1.4,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state,
        rating: 1, // failure
        currentTime: baseTime,
      );

      expect(nextState.easeFactor, 1.3);
    });

    test('Rejects invalid input', () {
      final state = LeitnerCardState(
        cardId: 'test1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
      );

      expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
          previousState: state,
          rating: -1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('DuplicatePreventingReviewCommandPort', () {
    test('Prevents duplicate commands by reviewId', () async {
      final mock = MockReviewCommandPort();
      final port = DuplicatePreventingReviewCommandPort(mock);

      final cmd1 = ReviewCommand(
        reviewId: 'rev1',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 123,
        rating: ReviewRating.good,
        hinted: false,
      );

      final cmd2 = ReviewCommand(
        reviewId: 'rev1', // Same ID
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 123,
        rating: ReviewRating.good,
        hinted: false,
      );

      await port.submit(cmd1);
      await port.submit(cmd2);

      expect(mock.commands.length, 1);
    });
  });

  group('Legacy compatibility', () {
    test('Legacy persisted review results handle mapping properly', () {
      final hardRatingFromIndex = SrsRating.values[0]; // Old 'hard'
      final goodRatingFromIndex = SrsRating.values[1]; // Old 'good'
      final easyRatingFromIndex = SrsRating.values[2]; // Old 'easy'

      expect(hardRatingFromIndex, SrsRating.hard);
      expect(goodRatingFromIndex, SrsRating.good);
      expect(easyRatingFromIndex, SrsRating.easy);
    });
  });
}
