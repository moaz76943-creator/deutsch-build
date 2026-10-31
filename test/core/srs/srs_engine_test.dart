import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';
import 'package:deutsch_bilarabi/core/srs/spaced_repetition_engine.dart';
import 'package:deutsch_bilarabi/core/srs/leitner_box_state.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

class MockReviewCommandPort implements ReviewCommandPort {
  final List<ReviewCommand> submittedCommands = [];

  @override
  Future<void> submit(ReviewCommand command) async {
    submittedCommands.add(command);
  }
}

void main() {
  group('ProductionSrsEngine tests', () {
    test('First review - easy', () {
      final now = DateTime(2024, 1, 1);
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 0,
        currentEaseFactor: 2.5,
        currentRepetitions: 0,
        rating: SrsRating.easy,
        currentTime: now,
      );

      expect(result.nextIntervalDays, 2);
      expect(result.easeFactor,
          2.65);
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
        currentTime: now,
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
        currentTime: now,
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
        currentTime: now,
      );

      expect(result.easeFactor, 1.3);

      result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 1.3,
        currentRepetitions: 1,
        rating: SrsRating.hard,
        currentTime: now,
      );

      expect(result.easeFactor, 1.3); // Minimum 1.3
    });

    test('Leap days', () {
      final now = DateTime(2024, 2, 28); // 2024 is leap year
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 1,
        currentEaseFactor: 2.5,
        currentRepetitions: 1,
        rating: SrsRating.good,
        currentTime: now,
      );

      expect(result.nextIntervalDays, 3);
      expect(result.nextReviewDate, DateTime(2024, 3, 2)); // 29, 1, 2
    });

    test('Rejects invalid negative inputs', () {
      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: -1,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: SrsRating.easy,
        ),
        throwsA(isA<Error>()),
      );

      expect(
        () => ProductionSrsEngine.processReview(
          currentIntervalDays: 0,
          currentEaseFactor: double.nan,
          currentRepetitions: 0,
          rating: SrsRating.easy,
        ),
        throwsA(isA<Error>()),
      );
    });
  });

  group('SpacedRepetitionEngine tests', () {
    test('calculateNextInterval - successful rating', () {
      const previousState = LeitnerCardState(
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
        currentTimeMs: 100000,
      );

      expect(nextState.currentBox, LeitnerBox.box2);
      expect(nextState.consecutiveSuccesses, 2);
      expect(nextState.easeFactor, 2.0); // No bonus for rating=2
      expect(nextState.nextReviewEpoch, 100000 + (3 * 86400000));
    });

    test('calculateNextInterval - failure rating', () {
      const previousState = LeitnerCardState(
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
        currentTimeMs: 100000,
      );

      expect(nextState.currentBox, LeitnerBox.box1);
      expect(nextState.consecutiveSuccesses, 0);
      expect(nextState.easeFactor, 1.8);
      expect(nextState.nextReviewEpoch, 100000 + (1 * 86400000));
    });

    test('LeitnerCardState isDueAt', () {
      const state = LeitnerCardState(
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
      expect(
        () => SpacedRepetitionEngine.calculateNextInterval(
          previousState: LeitnerCardState(
            cardId: 'c1',
            currentBox: LeitnerBox.box1,
            lastReviewedEpoch: 0,
            nextReviewEpoch: 0,
            easeFactor: double.nan,
            consecutiveSuccesses: 1,
          ),
          rating: 2,
        ),
        throwsA(isA<Error>()),
      );
    });
  });

  group('IdempotentReviewCommandPort tests', () {
    test('Prevents duplicate review-command application', () async {
      final mockDelegate = MockReviewCommandPort();
      final port = IdempotentReviewCommandPort(mockDelegate);

      const command1 = ReviewCommand(
        reviewId: 'r1',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      const command2 = ReviewCommand(
        reviewId: 'r1', // same id
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      const command3 = ReviewCommand(
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
    });
  });
}
