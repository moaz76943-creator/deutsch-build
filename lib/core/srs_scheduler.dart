import 'progress/review_transaction_envelope.dart';
import '../models/learner.dart';
import 'srs.dart';

abstract interface class SrsScheduler {
  ReviewCard schedule(
    ReviewCard current, {
    required bool correct,
    required bool hinted,
    DateTime? now,
  });
}

class UnifiedSrsScheduler implements SrsScheduler {
  const UnifiedSrsScheduler();
  static const UnifiedSrsScheduler instance = UnifiedSrsScheduler();

  static final List<ReviewTransactionEnvelope> _inMemoryJournal = [];

  @override
  ReviewCard schedule(
    ReviewCard current, {
    required bool correct,
    required bool hinted,
    DateTime? now,
  }) =>
      Srs.update(current, correct: correct, hinted: hinted, now: now);

  int xpRewardForReview({required bool correct, required bool hinted}) =>
      !correct ? 2 : (hinted ? 6 : 10);

  Future<void> processReviewTransaction(
      ReviewTransactionEnvelope envelope) async {
    // Legacy process-local history only; durable commits use TransactionPersistencePort.
    final alreadyExists = _inMemoryJournal.any(
      (e) => e.reviewEventId == envelope.reviewEventId,
    );
    if (!alreadyExists) {
      _inMemoryJournal.add(envelope);
    }
  }

  List<ReviewTransactionEnvelope> get history =>
      List.unmodifiable(_inMemoryJournal);
}

const UnifiedSrsScheduler unifiedSrsScheduler = UnifiedSrsScheduler();
