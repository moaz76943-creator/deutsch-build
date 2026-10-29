/// هوية المراجعة والتقييم لضمان عدم ازدواجية احتساب النقاط (XP)
/// ولضمان ارتباطها بالزوج اللغوي الموجه الصحيح.
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
    this.semanticVersion = '1.0.0',
    required this.cardId,
    required this.facetKey,
    required this.pairEpoch,
    required this.rating,
    required this.hinted,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewCommand &&
          runtimeType == other.runtimeType &&
          reviewId == other.reviewId;

  @override
  int get hashCode => reviewId.hashCode;

  /// Payload identity for one [reviewId]. A repeated id with a different
  /// pair, card, or rating is a conflict, not a silent replay.
  bool samePayloadAs(ReviewCommand other) {
    return sourceLanguageId == other.sourceLanguageId &&
        targetLanguageId == other.targetLanguageId &&
        semanticVersion == other.semanticVersion &&
        cardId == other.cardId &&
        facetKey == other.facetKey &&
        pairEpoch == other.pairEpoch &&
        rating == other.rating &&
        hinted == other.hinted;
  }
}

abstract interface class ReviewCommandPort {
  /// ترسل أمر التقييم إلى UnifiedSrsScheduler
  /// ليتم تنفيذه عبر Persistent CPU Worker وتخزينه كـ Atomic Transaction.
  Future<void> submit(ReviewCommand command);
}

/// Forwards each review id once. A repeated id is the same command, not a
/// second award of XP or a second schedule update.
class IdempotentReviewCommandPort implements ReviewCommandPort {
  IdempotentReviewCommandPort(this._delegate);

  final ReviewCommandPort _delegate;
  final Set<String> _seenReviewIds = <String>{};

  @override
  Future<void> submit(ReviewCommand command) async {
    if (!_seenReviewIds.add(command.reviewId)) return;
    await _delegate.submit(command);
  }
}
