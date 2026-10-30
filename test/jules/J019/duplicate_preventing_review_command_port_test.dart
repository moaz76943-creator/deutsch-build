
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'package:deutsch_bilarabi/core/progress/duplicate_preventing_review_command_port.dart';
import 'package:flutter_test/flutter_test.dart';

class MockReviewCommandPort implements ReviewCommandPort {
  int submitCallCount = 0;
  bool shouldFail = false;

  @override
  Future<void> submit(ReviewCommand command) async {
    if (shouldFail) {
      throw Exception('Simulated storage failure');
    }
    submitCallCount++;
  }
}

void main() {
  group('DuplicatePreventingReviewCommandPort J019 Tests', () {
    late MockReviewCommandPort mockDelegate;
    late DuplicatePreventingReviewCommandPort portAB;
    late DuplicatePreventingReviewCommandPort portBA;

    setUp(() {
      mockDelegate = MockReviewCommandPort();
      portAB = DuplicatePreventingReviewCommandPort(
        delegate: mockDelegate,
        expectedLanguagePairKey: 'en_de',
      );
      portBA = DuplicatePreventingReviewCommandPort(
        delegate: mockDelegate,
        expectedLanguagePairKey: 'de_en',
      );
    });

    test('accepts valid command and delegates', () async {
      final command = ReviewCommand(
        reviewId: 'r1',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      await portAB.submit(command);
      expect(mockDelegate.submitCallCount, 1);
    });

    test('rejects duplicate commands (idempotency)', () async {
      final command = ReviewCommand(
        reviewId: 'r2',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'c2',
        facetKey: 'f2',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      );

      await portAB.submit(command);
      await portAB.submit(command); // duplicate
      await portAB.submit(command); // duplicate

      expect(mockDelegate.submitCallCount, 1);
    });

    test('rejects commands for wrong language pair', () async {
      final commandWrong = ReviewCommand(
        reviewId: 'r3',
        sourceLanguageId: 'fr',
        targetLanguageId: 'de',
        cardId: 'c3',
        facetKey: 'f3',
        pairEpoch: 1,
        rating: ReviewRating.easy,
        hinted: false,
      );

      expect(
        () => portAB.submit(commandWrong),
        throwsA(isA<ArgumentError>()),
      );
      expect(mockDelegate.submitCallCount, 0);
    });

    test('rejects commands for reverse language pair', () async {
      final commandReverse = ReviewCommand(
        reviewId: 'r4',
        sourceLanguageId: 'de',
        targetLanguageId: 'en',
        cardId: 'c4',
        facetKey: 'f4',
        pairEpoch: 1,
        rating: ReviewRating.again,
        hinted: false,
      );

      // A->B port should reject B->A command
      expect(
        () => portAB.submit(commandReverse),
        throwsA(isA<ArgumentError>()),
      );
      expect(mockDelegate.submitCallCount, 0);

      // B->A port should accept B->A command
      await portBA.submit(commandReverse);
      expect(mockDelegate.submitCallCount, 1);
    });

    test('handles simulated storage failure and allows retry (recoverable)', () async {
      final command = ReviewCommand(
        reviewId: 'r5',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        cardId: 'c5',
        facetKey: 'f5',
        pairEpoch: 1,
        rating: ReviewRating.hard,
        hinted: false,
      );

      mockDelegate.shouldFail = true;

      // First attempt fails
      try {
        await portAB.submit(command);
      } catch (e) {
        expect(e, isA<Exception>());
      }
      expect(mockDelegate.submitCallCount, 0);

      // Second attempt succeeds
      mockDelegate.shouldFail = false;
      await portAB.submit(command);
      expect(mockDelegate.submitCallCount, 1);

      // Third attempt is ignored (idempotency)
      await portAB.submit(command);
      expect(mockDelegate.submitCallCount, 1);
    });
  });
}
