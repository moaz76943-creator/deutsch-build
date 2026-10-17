import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

void main() {
  test('ReviewCommand equality and hashCode based on reviewId', () {
    const command1 = ReviewCommand(
      reviewId: 'id_123',
      sourceLanguageId: 'en',
      targetLanguageId: 'de',
      cardId: 'card_1',
      facetKey: 'facet_1',
      pairEpoch: 1,
      rating: ReviewRating.good,
      hinted: false,
    );

    const command2 = ReviewCommand(
      reviewId: 'id_123', // Same ID
      sourceLanguageId: 'en',
      targetLanguageId: 'de',
      cardId: 'card_2', // Different card
      facetKey: 'facet_2',
      pairEpoch: 2,
      rating: ReviewRating.hard, // Different rating
      hinted: true,
    );

    const command3 = ReviewCommand(
      reviewId: 'id_456', // Different ID
      sourceLanguageId: 'en',
      targetLanguageId: 'de',
      cardId: 'card_1',
      facetKey: 'facet_1',
      pairEpoch: 1,
      rating: ReviewRating.good,
      hinted: false,
    );

    expect(command1, equals(command2));
    expect(command1.hashCode, equals(command2.hashCode));

    expect(command1, isNot(equals(command3)));
    expect(command1.hashCode, isNot(equals(command3.hashCode)));
  });
}
