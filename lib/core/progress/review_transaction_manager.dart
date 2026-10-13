import 'review_transaction_envelope.dart';
import 'transaction_persistence_port.dart';
import 'transaction_state.dart';
import '../srs/review_command_port.dart';

class ReviewTransactionManager {
  final TransactionPersistencePort persistencePort;

  ReviewTransactionManager(this.persistencePort);

  Future<void> processTransaction(
    ReviewCommand command,
    Future<void> Function() performCommit,
  ) async {
    final String languagePairKey = '${command.sourceLanguageId}->${command.targetLanguageId}';

    final ReviewTransactionEnvelope envelope = ReviewTransactionEnvelope(
      reviewEventId: command.reviewId,
      learnerContentKey: command.cardId,
      rating: command.rating.index,
      timestamp: DateTime.now(),
      languagePairKey: languagePairKey,
    );

    final existingState = await persistencePort.getTransactionState(command.reviewId);
    final existingEnvelope = await persistencePort.getTransactionEnvelope(command.reviewId);

    if (existingState != null && existingEnvelope != null) {
      if (existingEnvelope.languagePairKey != languagePairKey ||
          existingEnvelope.learnerContentKey != command.cardId ||
          existingEnvelope.rating != command.rating.index) {
        throw Exception('Duplicate command with conflicting data for reviewId: ${command.reviewId}');
      }

      if (existingState == TransactionState.committed) {
        return; // Idempotent success
      }
    }

    if (existingState == null) {
      await persistencePort.saveTransaction(envelope, TransactionState.pending);
    } else {
      await persistencePort.updateTransactionState(command.reviewId, TransactionState.pending);
    }

    try {
      await performCommit();
      await persistencePort.updateTransactionState(command.reviewId, TransactionState.committed);
    } catch (e) {
      // Depending on the exact failure type we might want to distinguish between failed and recoverable,
      // but for this implementation we can consider commit failures as recoverable.
      await persistencePort.updateTransactionState(command.reviewId, TransactionState.recoverable);
      rethrow;
    }
  }
}
