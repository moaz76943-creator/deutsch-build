import 'dart:collection';
/// هوية المراجعة والتقييم لضمان عدم ازدواجية احتساب النقاط (XP)
/// ولضمان ارتباطها بالزوج اللغوي الموجه الصحيح.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewCommand &&
          runtimeType == other.runtimeType &&
          reviewId == other.reviewId;

  @override
  int get hashCode => reviewId.hashCode;
}

abstract interface class ReviewCommandPort {
  /// ترسل أمر التقييم إلى UnifiedSrsScheduler
  /// ليتم تنفيذه عبر Persistent CPU Worker وتخزينه كـ Atomic Transaction.
  Future<void> submit(ReviewCommand command);
}

class IdempotentReviewCommandPort implements ReviewCommandPort {
  final ReviewCommandPort _delegate;
  final LinkedHashSet<String> _processedReviewIds = LinkedHashSet<String>();
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
