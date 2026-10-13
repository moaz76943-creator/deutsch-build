import '../srs/review_command_port.dart';
import 'review_transaction_envelope.dart';
import 'transaction_persistence_port.dart';

/// Validates commands and delegates all state mutation to one atomic store.
/// Do not connect this to an in-memory implementation in production.
class ReviewTransactionManager implements ReviewCommandPort {
  final TransactionPersistencePort persistencePort;
  final DateTime Function() clock;

  ReviewTransactionManager(
    this.persistencePort, {
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  Future<TransactionCommitOutcome> processTransaction(ReviewCommand command) async {
    if (command.reviewId.trim().isEmpty ||
        command.cardId.trim().isEmpty ||
        command.facetKey.trim().isEmpty ||
        command.sourceLanguageId.trim().isEmpty ||
        command.targetLanguageId.trim().isEmpty ||
        command.sourceLanguageId == command.targetLanguageId ||
        command.pairEpoch < 0) {
      throw ArgumentError('Invalid review identity or directed language pair');
    }

    final envelope = ReviewTransactionEnvelope(
      reviewEventId: command.reviewId,
      learnerContentKey: command.cardId,
      rating: command.rating.index,
      timestamp: clock().toUtc(),
      // Match the current runtime pair prefix. The durable port MUST also
      // include pairEpoch and facetKey from command in its unique identity.
      languagePairKey:
          command.sourceLanguageId + '_' + command.targetLanguageId,
    );
    return await persistencePort.commitReviewAtomically(
      command: command,
      envelope: envelope,
    );
  }

  @override
  Future<void> submit(ReviewCommand command) async {
    await processTransaction(command);
  }
}
