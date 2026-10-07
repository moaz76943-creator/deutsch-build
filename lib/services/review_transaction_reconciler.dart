import '../core/progress/offline_pair_progress_engine.dart';
import '../core/progress/review_transaction_envelope.dart';
import '../features/gamification/domain/gamification_models.dart';
import '../features/gamification/gamification_repository.dart';
import '../models/learner.dart';
import 'learner_persistence.dart';

final class ReviewTransactionReconciler {
  const ReviewTransactionReconciler({
    required this.pairProgressEngine,
    required this.learnerPersistence,
    required this.gamificationRepository,
  });

  static const int maxBatchSize = 128;

  final OfflinePairProgressEngine pairProgressEngine;
  final LearnerPersistence learnerPersistence;
  final GamificationRepository gamificationRepository;

  Future<ReviewReconciliationReport> reconcilePendingReviewTransactions({
    int limit = maxBatchSize,
  }) async {
    final boundedLimit = limit.clamp(1, maxBatchSize).toInt();
    final pending = await pairProgressEngine.loadPendingReviewTransactions(
      limit: boundedLimit,
    );

    var attemptsAcknowledged = 0;
    var gamificationAcknowledged = 0;
    var completed = 0;

    for (final entry in pending) {
      if (!entry.attemptApplied) {
        await _reconcileAttempt(entry);
        await pairProgressEngine.acknowledgeReviewTransaction(
          reviewEventId: entry.envelope.reviewEventId,
          payloadHash: entry.payloadHash,
          sink: ReviewTransactionSink.attempt,
        );
        attemptsAcknowledged += 1;
      }

      if (!entry.gamificationApplied) {
        await _reconcileGamification(entry);
        await pairProgressEngine.acknowledgeReviewTransaction(
          reviewEventId: entry.envelope.reviewEventId,
          payloadHash: entry.payloadHash,
          sink: ReviewTransactionSink.gamification,
        );
        gamificationAcknowledged += 1;
      }

      completed += 1;
    }

    return ReviewReconciliationReport(
      inspected: pending.length,
      attemptsAcknowledged: attemptsAcknowledged,
      gamificationAcknowledged: gamificationAcknowledged,
      completed: completed,
    );
  }

  Future<ReviewReconciliationReport> reconcilePending({
    int limit = maxBatchSize,
  }) =>
      reconcilePendingReviewTransactions(limit: limit);

  Future<void> _reconcileAttempt(
    ReviewTransactionJournalEntry entry,
  ) async {
    final envelope = entry.envelope;
    await learnerPersistence.applyReviewAttemptOnce(
      reviewEventId: envelope.reviewEventId,
      attempt: Attempt(
        id: envelope.reviewEventId,
        itemId: envelope.conceptId,
        skill: envelope.skill,
        answer: envelope.answer,
        correct: envelope.correct,
        hinted: envelope.hinted,
        seconds: envelope.seconds,
        at: envelope.occurredAtUtc,
        facetType: envelope.facetType,
        variantKey: envelope.variantKey,
      ),
    );
  }

  Future<void> _reconcileGamification(
    ReviewTransactionJournalEntry entry,
  ) async {
    final envelope = entry.envelope;
    await gamificationRepository.recordReview(
      GamificationReviewEvent(
        reviewId: envelope.reviewEventId,
        facetType: envelope.facetType,
        correct: envelope.correct,
        hinted: envelope.hinted,
        requestedXp: envelope.requestedXp,
        occurredAtUtc: envelope.occurredAtUtc,
        timezoneOffsetMinutes: envelope.timezoneOffsetMinutes,
      ),
    );
  }
}

final class ReviewReconciliationReport {
  const ReviewReconciliationReport({
    required this.inspected,
    required this.attemptsAcknowledged,
    required this.gamificationAcknowledged,
    required this.completed,
  });

  final int inspected;
  final int attemptsAcknowledged;
  final int gamificationAcknowledged;
  final int completed;
}
