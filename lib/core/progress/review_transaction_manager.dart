import '../srs/review_command_port.dart';
import 'review_transaction_envelope.dart';
import 'transaction_persistence_port.dart';

/// Pure coordinator. The storage implementation MUST provide atomic
/// event deduplication AND review/progress mutation in one local DB transaction.
/// An in-memory journal or a separate "mark committed" call is not compliant.
class ReviewTransactionManager {
  final TransactionPersistencePort persistencePort;
  final DateTime Function() clock;

  ReviewTransactionManager(this.persistencePort, {DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  Future<ReviewCommitResult> processTransaction(ReviewCommand command) async {
    if (command.reviewId.trim().isEmpty ||
        command.cardId.trim().isEmpty ||
        command.facetKey.trim().isEmpty ||
        command.sourceLanguageId.trim().isEmpty ||
        command.targetLanguageId.trim().isEmpty ||
        command.sourceLanguageId == command.targetLanguageId ||
        command.pairEpoch < 0) {
      throw ArgumentError('Malformed review command or directed pair');
    }

    final envelope = ReviewTransactionEnvelope(
      reviewEventId: command.reviewId,
      learnerContentKey: command.cardId,
      rating: command.rating.index,
      timestamp: clock().toUtc(),
      languagePairKey:
          '${command.sourceLanguageId}_${command.targetLanguageId}',
    );
    // Never infer success after an interrupted commit. The atomic port
    // resolves retries and rejects same-ID, different-payload collisions.
    return persistencePort.commitOnce(
      command: command,
      envelope: envelope,
    );
  }
}
