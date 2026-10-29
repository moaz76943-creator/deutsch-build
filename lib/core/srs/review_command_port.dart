import 'dart:async';

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

/// Forwards each successfully committed review ID only once.
///
/// Pending duplicates await the original result; a failed write must never
/// consume an event ID, otherwise a user retry silently loses the review.
/// This is an in-process guard, not a substitute for the durable UNIQUE-event
/// journal and atomic SQLite transaction at the persistence boundary.
class IdempotentReviewCommandPort implements ReviewCommandPort {
  IdempotentReviewCommandPort(this._delegate);

  final ReviewCommandPort _delegate;
  final Map<String, ReviewCommand> _committed = <String, ReviewCommand>{};
  final Map<String, (ReviewCommand, Future<void>)> _pending =
      <String, (ReviewCommand, Future<void>)>{};

  @override
  Future<void> submit(ReviewCommand command) {
    final previous = _committed[command.reviewId];
    if (previous != null) {
      if (!previous.samePayloadAs(command)) {
        return Future<void>.error(
          StateError('Review ID reused with a conflicting payload'),
        );
      }
      return Future<void>.value();
    }

    final pending = _pending[command.reviewId];
    if (pending != null) {
      if (!pending.$1.samePayloadAs(command)) {
        return Future<void>.error(
          StateError('Review ID reused with a conflicting payload'),
        );
      }
      return pending.$2;
    }

    // Reserve synchronously before the first asynchronous storage operation,
    // so same-tick duplicates cannot launch separate writes.
    final completion = Completer<void>();
    _pending[command.reviewId] = (command, completion.future);
    _forward(command, completion);
    return completion.future;
  }

  Future<void> _forward(
    ReviewCommand command,
    Completer<void> completion,
  ) async {
    try {
      await _delegate.submit(command);
      _committed[command.reviewId] = command;
      completion.complete();
    } catch (error, stackTrace) {
      // Never acknowledge a failed write or block its later retry.
      completion.completeError(error, stackTrace);
    } finally {
      _pending.remove(command.reviewId);
    }
  }
}
