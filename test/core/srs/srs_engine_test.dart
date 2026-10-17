import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';
import 'package:deutsch_bilarabi/core/srs/spaced_repetition_engine.dart';
import 'package:deutsch_bilarabi/core/srs/leitner_box_state.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

class MockReviewCommandPort implements ReviewCommandPort {
<<<<<<< HEAD
  final List<ReviewCommand> submittedCommands = [];

  @override
  Future<void> submit(ReviewCommand command) async {
    submittedCommands.add(command);
=======
  final List<ReviewCommand> commands = [];
  @override
  Future<void> submit(ReviewCommand command) async {
    commands.add(command);
>>>>>>> origin/main
  }
}

void main() {
<<<<<<< HEAD
  group('ProductionSrsEngine tests', () {
    test('First review - easy', () {
      final now = DateTime(2024, 1, 1);
=======
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
>>>>>>> origin/main
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 0,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.easy,
<<<<<<< HEAD
        now: now,
      );

      expect(result.nextIntervalDays, 2);
      expect(result.easeFactor, 2.5); // min(2.5, 2.5 + 0.15) clamped to 2.5? min(2.5, 2.65) is 2.5. actually wait, min(2.5, 2.5 + 0.15) == 2.5. Let's see: math.max(1.3, math.min(2.5, currentEaseFactor + 0.15)) -> 2.5.
      expect(result.repetitionCount, 1);
      expect(result.nextReviewDate, DateTime(2024, 1, 3));
    });

    test('Repeated failures', () {
      final now = DateTime(2024, 1, 1);
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 10,
        currentEaseFactor: 2.0,
        currentRepetitions: 3,
        rating: SrsRating.hard,
        now: now,
      );

      expect(result.nextIntervalDays, 1);
      expect(result.easeFactor, 1.8);
      expect(result.repetitionCount, 0);
      expect(result.nextReviewDate, DateTime(2024, 1, 2));
    });

    test('Successful recall', () {
      final now = DateTime(2024, 1, 1);
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 10,
        currentEaseFactor: 2.0,
        currentRepetitions: 3,
        rating: SrsRating.easy,
        now: now,
      );

      expect(result.nextIntervalDays, 26); // (10 * 2.0 * 1.3).round() = 26
      expect(result.easeFactor, 2.15);
      expect(result.repetitionCount, 4);
      expect(result.nextReviewDate, DateTime(2024, 1, 27));
    });

    test('Ease-factor boundaries', () {
      final now = DateTime(2024, 1, 1);
      var result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 1.4,
        currentRepetitions: 1,
        rating: SrsRating.hard,
        now: now,
      );

      expect(result.easeFactor, 1.3);

      result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 1.3,
        currentRepetitions: 1,
        rating: SrsRating.hard,
        now: now,
      );

      expect(result.easeFactor, 1.3); // Minimum 1.3
    });

    test('Leap days', () {
      final now = DateTime(2024, 2, 28); // 2024 is leap year
=======
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
>>>>>>> origin/main
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 2.5,
        currentRepetitions: 1,
        rating: SrsRating.good,
<<<<<<< HEAD
        now: now,
      );

      expect(result.nextIntervalDays, 3);
      expect(result.nextReviewDate, DateTime(2024, 3, 2)); // 29, 1, 2
    });

    test('Rejects invalid negative inputs', () {
=======
        currentTime: leapTime,
      );

      expect(result.nextIntervalDays, 3);
      // Feb 28 + 3 days -> March 2 (2024 is a leap year)
      expect(result.nextReviewDate, DateTime(2024, 3, 2));
    });

    test('Rejects invalid input', () {
>>>>>>> origin/main
      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: -1,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
<<<<<<< HEAD
          rating: SrsRating.easy,
=======
          rating: SrsRating.good,
>>>>>>> origin/main
        ),
        throwsArgumentError,
      );

      expect(
        () => ProductionSrsEngine.processReview(
<<<<<<< HEAD
          currentIntervalDays: 0,
          currentEaseFactor: double.nan,
          currentRepetitions: 0,
          rating: SrsRating.easy,
=======
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
>>>>>>> origin/main
        ),
        throwsArgumentError,
      );
    });
  });

<<<<<<< HEAD
  group('SpacedRepetitionEngine tests', () {
    test('calculateNextInterval - successful rating', () {
      final previousState = LeitnerCardState(
        cardId: 'c1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
        easeFactor: 2.0,
        consecutiveSuccesses: 1,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: previousState,
        rating: 2, // good
        nowEpoch: 1000,
      );

      expect(nextState.currentBox, LeitnerBox.box2);
      expect(nextState.consecutiveSuccesses, 2);
      expect(nextState.easeFactor, 2.0); // No bonus for rating=2
      expect(nextState.nextReviewEpoch, 1000 + (3 * 86400000));
    });

    test('calculateNextInterval - failure rating', () {
      final previousState = LeitnerCardState(
        cardId: 'c1',
        currentBox: LeitnerBox.box3,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
        easeFactor: 2.0,
        consecutiveSuccesses: 5,
      );

      final nextState = SpacedRepetitionEngine.calculateNextInterval(
        previousState: previousState,
        rating: 1, // hard/fail
        nowEpoch: 1000,
=======
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
>>>>>>> origin/main
      );

      expect(nextState.currentBox, LeitnerBox.box1);
      expect(nextState.consecutiveSuccesses, 0);
<<<<<<< HEAD
      expect(nextState.easeFactor, 1.8);
      expect(nextState.nextReviewEpoch, 1000 + (1 * 86400000));
    });

    test('LeitnerCardState isDueAt', () {
      final state = LeitnerCardState(
        cardId: 'c1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 1000,
      );

      expect(state.isDueAt(999), isFalse);
      expect(state.isDueAt(1000), isTrue);
      expect(state.isDueAt(1001), isTrue);
    });

    test('Rejects invalid negative inputs', () {
      final previousState = LeitnerCardState(
        cardId: 'c1',
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: 0,
        nextReviewEpoch: 0,
        easeFactor: double.nan,
        consecutiveSuccesses: 1,
=======
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
>>>>>>> origin/main
      );

      expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
<<<<<<< HEAD
          previousState: previousState,
          rating: 2,
=======
          previousState: state,
          rating: -1,
>>>>>>> origin/main
        ),
        throwsArgumentError,
      );
    });
  });

<<<<<<< HEAD
  group('IdempotentReviewCommandPort tests', () {
    test('Prevents duplicate review-command application', () async {
      final mockDelegate = MockReviewCommandPort();
      final port = IdempotentReviewCommandPort(mockDelegate);

      final command1 = ReviewCommand(
        reviewId: 'r1',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 1,
=======
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
>>>>>>> origin/main
        rating: ReviewRating.good,
        hinted: false,
      );

<<<<<<< HEAD
      final command2 = ReviewCommand(
        reviewId: 'r1', // same id
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 1,
=======
      final cmd2 = ReviewCommand(
        reviewId: 'rev1', // Same ID
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 123,
>>>>>>> origin/main
        rating: ReviewRating.good,
        hinted: false,
      );

<<<<<<< HEAD
      final command3 = ReviewCommand(
        reviewId: 'r2', // different id
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      await port.submit(command1);
      await port.submit(command2);
      await port.submit(command3);

      expect(mockDelegate.submittedCommands.length, 2);
      expect(mockDelegate.submittedCommands[0].reviewId, 'r1');
      expect(mockDelegate.submittedCommands[1].reviewId, 'r2');
=======
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
>>>>>>> origin/main
    });
  });
}
