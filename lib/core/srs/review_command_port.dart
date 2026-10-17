/// Immutable, versioned, directed-pair review identity.
enum ReviewRating { again, hard, good, easy }

class ReviewCommand {
  final String reviewId;
  final String sourceLanguageId;
  final String targetLanguageId;
  final String semanticVersion;
  final String cardId;
  final String facetKey;
  final int pairEpoch;
  final ReviewRating rating;
  final bool hinted;

  const ReviewCommand({
    required this.reviewId,
    required this.sourceLanguageId,
    required this.targetLanguageId,
    required this.semanticVersion,
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
      semanticVersion == other.semanticVersion &&
      cardId == other.cardId &&
      facetKey == other.facetKey &&
      pairEpoch == other.pairEpoch &&
      rating == other.rating &&
      hinted == other.hinted;
}

abstract interface class ReviewCommandPort {
  /// Only a durable transaction-backed implementation may acknowledge success.
  Future<void> submit(ReviewCommand command);
}

class IdempotentReviewCommandPort implements ReviewCommandPort {
  final ReviewCommandPort _delegate;
  final Set<String> _processedReviewIds = {};
  static const int _maxCacheSize = 1000;

  IdempotentReviewCommandPort(this._delegate);

  @override
  Future<void> submit(ReviewCommand command) async {
    if (_processedReviewIds.contains(command.reviewId)) {
      return;
    }
    if (_processedReviewIds.length >= _maxCacheSize) {
      _processedReviewIds.remove(_processedReviewIds.first);
    }
    _processedReviewIds.add(command.reviewId);
    await _delegate.submit(command);
  }
}
