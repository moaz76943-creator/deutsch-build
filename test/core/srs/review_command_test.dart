import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

void main() {
  group('ReviewCommand Deduplication Tests', () {
    test('Identical reviewIds are considered equal', () {
      const cmd1 = ReviewCommand(
        reviewId: 'rev-123',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'card-abc',
        facetKey: 'vocab',
        pairEpoch: 1000,
        rating: ReviewRating.good,
        hinted: false,
      );

      const cmd2 = ReviewCommand(
        reviewId: 'rev-123',
        sourceLanguageId: 'en', // Different payload
        targetLanguageId: 'ar',
        cardId: 'card-xyz',
        facetKey: 'grammar',
        pairEpoch: 2000,
        rating: ReviewRating.easy,
        hinted: true,
      );

      const cmd3 = ReviewCommand(
        reviewId: 'rev-999',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'card-abc',
        facetKey: 'vocab',
        pairEpoch: 1000,
        rating: ReviewRating.good,
        hinted: false,
      );

      expect(cmd1 == cmd2, isTrue); // Same ID
      expect(cmd1.hashCode == cmd2.hashCode, isTrue);

      expect(cmd1 == cmd3, isFalse); // Different ID
      expect(cmd1.hashCode == cmd3.hashCode, isFalse);
    });

    test('Set insertion deduplicates by reviewId', () {
      final set = <ReviewCommand>{};

      set.add(const ReviewCommand(
        reviewId: 'rev-001',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      ));

      set.add(const ReviewCommand(
        reviewId: 'rev-001',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        cardId: 'c1',
        facetKey: 'f1',
        pairEpoch: 1,
        rating: ReviewRating.good,
        hinted: false,
      ));

      expect(set.length, 1);
    });
  });
}
