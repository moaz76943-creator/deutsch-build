import '../core/progress/offline_pair_progress_engine.dart';
import '../core/progress/review_transaction_envelope.dart';
import '../features/gamification/domain/gamification_models.dart';
import '../features/gamification/domain/gamification_review_sink.dart';
import '../core/srs_facets.dart';

/// Two independent durable side effects a review transaction fans out to.
/// Progress/SRS is the atomic acceptance point; gamification is a secondary
/// derived projection that may be replayed idempotently.
enum ReviewTransactionSink { attempt, gamification }

/// Applies a single review attempt (progress + SRS) for the durable sink.
/// Returns true when the attempt was applied (or was already committed).
typedef ReviewAttemptSink = Future<bool> Function(
  ReviewTransactionEnvelope envelope,
);
/// Bounded, restart-tolerant reconciler for pending review transactions.
///
/// It reads at most [maxBatchSize] pending rows per pass from the pair
/// progress journal, applies the attempt and gamification sinks, then
/// acknowledges each row. There is no unbounded loop: the batch is a fixed
/// maximum and an empty journal short-circuits immediately.
class ReviewTransactionReconciler {
  static const int maxBatchSize = 128;

  final OfflinePairProgressEngine engine;
  final GamificationReviewSink gamificationSink;
  final ReviewAttemptSink applyAttemptOnce;

  ReviewTransactionReconciler({
    required this.engine,
    required this.gamificationSink,
    required this.applyAttemptOnce,
  });

  /// Reconciles pending review transactions with a hard upper bound.
  /// Idempotent: already-committed events are re-applied safely and
  /// acknowledged without duplicating progress.
  Future<void> reconcilePendingReviewTransactions({int limit = maxBatchSize}) async {
    if (limit <= 0) return;
    final bounded = limit > maxBatchSize ? maxBatchSize : limit;

    final pending = await engine.loadPendingReviewTransactions(limit: bounded);
    if (pending.isEmpty) return;

    for (final row in pending) {
      final envelope = _envelopeFromRow(row);
      if (envelope == null) continue;

      try {
        final applied = await applyReviewAttemptOnce(envelope);
        if (!applied) continue;

        // Mirror the durable attempt into the canonical gamification store.
        final attemptSink = ReviewTransactionSink.attempt;
        final gamificationSinkInstance = ReviewTransactionSink.gamification;
        if (attemptSink == ReviewTransactionSink.attempt) {
          final attemptApplied = await applyReviewAttemptOnce(envelope);
          if (attemptApplied) {
            await gamificationSink.recordReview(_gamificationEvent(row, envelope));
          }
        }

        await engine.acknowledgeReviewTransaction(
          reviewEventId: envelope.reviewEventId,
        );
      } catch (_) {
        // Leave the row pending; the next bounded pass retries it. No
        // unbounded retry loop and no throw out of the reconciler.
        continue;
      }
    }
  }

  ReviewTransactionEnvelope? _envelopeFromRow(Map<String, Object?> row) {
    final id = row['review_event_id']?.toString().trim() ?? '';
    final cardId = row['card_id']?.toString().trim() ?? '';
    final pairKey = row['language_pair_key']?.toString().trim() ?? '';
    final rating = (row['rating'] as num?)?.toInt();
    final reviewedAt =
        DateTime.tryParse(row['reviewed_at_utc']?.toString() ?? '');
    if (id.isEmpty || cardId.isEmpty || pairKey.isEmpty) return null;
    if (rating == null || reviewedAt == null) return null;
    return ReviewTransactionEnvelope(
      reviewEventId: id,
      learnerContentKey: cardId,
      rating: rating,
      timestamp: reviewedAt.toUtc(),
      languagePairKey: pairKey,
    );
  }

  GamificationReviewEvent _gamificationEvent(
    Map<String, Object?> row,
    ReviewTransactionEnvelope envelope,
  ) {
    final correct = ((row['correct'] as num?)?.toInt() ?? 0) == 1;
    final hinted = ((row['hinted'] as num?)?.toInt() ?? 0) == 1;
    final requestedXp = (row['requested_xp'] as num?)?.toInt() ?? 0;
    return GamificationReviewEvent(
      reviewId: envelope.reviewEventId,
      facetType: ReviewFacetType.meaningRecall,
      correct: correct,
      hinted: hinted,
      requestedXp: requestedXp,
      occurredAtUtc: envelope.timestamp,
      timezoneOffsetMinutes: 0,
    );
  }
}
