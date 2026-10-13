/// An immutable, directed-pair-specific review command.
/// reviewId is a globally unique event key; a colliding payload is an error.
enum ReviewRating { again, hard, good, easy }

class ReviewCommand {
  final String reviewId;
  final String sourceLanguageId;
  final String targetLanguageId;
  final String cardId;
  final String facetKey;
  final int pairEpoch;
  final ReviewRating rating;
  final bool hinted;

  const ReviewCommand({
    required this.reviewId,
    required this.sourceLanguageId,
    required this.targetLanguageId,
    required this.cardId,
    required this.facetKey,
    required this.pairEpoch,
    required this.rating,
    required this.hinted,
  });

  bool samePayloadAs(ReviewCommand other) =>
      reviewId == other.reviewId &&
      sourceLanguageId == other.sourceLanguageId &&
      targetLanguageId == other.targetLanguageId &&
      cardId == other.cardId &&
      facetKey == other.facetKey &&
      pairEpoch == other.pairEpoch &&
      rating == other.rating &&
      hinted == other.hinted;
}

abstract interface class ReviewCommandPort {
  /// Implementation must use the one persistent, worker-backed SRS authority.
  Future<void> submit(ReviewCommand command);
}
