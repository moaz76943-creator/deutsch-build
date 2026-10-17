import '../srs/review_command_port.dart';
import 'review_transaction_envelope.dart';
import 'transaction_state.dart';

class ReviewTransactionManager {
  final Map<String, TransactionState> _transactions = {};

  String _deriveLanguagePairKey(ReviewCommand command) {
    return '${command.sourceLanguageId}_${command.targetLanguageId}';
  }

  void restoreHistory(List<ReviewTransactionEnvelope> history) {
    for (final envelope in history) {
      _transactions[envelope.reviewEventId] = TransactionCommitted(envelope);
    }
  }

  TransactionState getTransactionState(String reviewEventId) {
    return _transactions[reviewEventId] ?? TransactionRecoverable(Exception('Not found')); // Just for querying if needed, or maybe just exposing the map
  }

  Future<TransactionState> executeTransaction(
    ReviewCommand command,
    Future<void> Function(ReviewTransactionEnvelope) commitFn,
  ) async {
    if (command.reviewId.isEmpty) {
      return TransactionFailed(ArgumentError('reviewId cannot be empty'));
    }

    final languagePairKey = _deriveLanguagePairKey(command);

    final existingState = _transactions[command.reviewId];

    if (existingState is TransactionPending) {
      return TransactionFailed(StateError('Transaction already pending'));
    }

    if (existingState is TransactionCommitted) {
      if (existingState.envelope.languagePairKey == languagePairKey) {
        return existingState; // Idempotent success
      } else {
        return TransactionFailed(
            StateError('Transaction already committed for a different language pair'));
      }
    }

    _transactions[command.reviewId] = TransactionPending();

    final envelope = ReviewTransactionEnvelope(
      reviewEventId: command.reviewId,
      learnerContentKey: command.cardId,
      rating: command.rating.index,
      timestamp: DateTime.now(), // Or we could inject time
      languagePairKey: languagePairKey,
    );

    try {
      await commitFn(envelope);
      final committedState = TransactionCommitted(envelope);
      _transactions[command.reviewId] = committedState;
      return committedState;
    } catch (e) {
      // Depending on the error we could return Recoverable or Failed
      // For now, let's treat general exceptions as Recoverable so they can be retried
      final recoverableState = TransactionRecoverable(e);
      _transactions[command.reviewId] = recoverableState;
      return recoverableState;
    }
  }
}
