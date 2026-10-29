import '../srs/review_command_port.dart';
import 'review_transaction_envelope.dart';
import 'transaction_state.dart';

typedef PersistenceHandler = Future<void> Function(ReviewTransactionEnvelope envelope);

class ReviewTransactionManager {
  final PersistenceHandler? persistenceHandler;
  final Map<String, TransactionState> _states = {};
  final Map<String, ReviewTransactionEnvelope> _envelopes = {};
  final Map<String, TransactionState> _transactions = {};

  ReviewTransactionManager({this.persistenceHandler});

  Future<TransactionState> processTransaction(
    ReviewTransactionEnvelope envelope,
    String activeLanguagePairKey,
  ) async {
    if (envelope.languagePairKey != activeLanguagePairKey) {
      return const TransactionStateFailed('Language pair mismatch');
    }

    final existingState = _states[envelope.reviewEventId];
    if (existingState != null) {
      final existingEnvelope = _envelopes[envelope.reviewEventId]!;
      if (!_envelopesAreEqual(existingEnvelope, envelope)) {
        return const TransactionStateFailed('Duplicate review ID with different payload');
      }

      if (existingState is TransactionStateCommitted) {
        return existingState;
      }
      if (existingState is TransactionStatePending) {
        return existingState;
      }
    }

    _states[envelope.reviewEventId] = const TransactionStatePending();
    _envelopes[envelope.reviewEventId] = envelope;

    try {
      if (persistenceHandler != null) {
        await persistenceHandler!(envelope);
      }
      _states[envelope.reviewEventId] = const TransactionStateCommitted();
      return const TransactionStateCommitted();
    } catch (e) {
      _states[envelope.reviewEventId] = TransactionStateRecoverable(e);
      return TransactionStateRecoverable(e);
    }
  }

  void restoreSession(List<ReviewTransactionEnvelope> history) {
    for (final envelope in history) {
      _states[envelope.reviewEventId] = const TransactionStateCommitted();
      _envelopes[envelope.reviewEventId] = envelope;
    }
  }

  bool _envelopesAreEqual(ReviewTransactionEnvelope a, ReviewTransactionEnvelope b) {
    return a.learnerContentKey == b.learnerContentKey &&
        a.rating == b.rating &&
        a.timestamp == b.timestamp &&
        a.languagePairKey == b.languagePairKey;
  }

  String _deriveLanguagePairKey(ReviewCommand command) {
    return '${command.sourceLanguageId}_${command.targetLanguageId}';
  }

  void restoreHistory(List<ReviewTransactionEnvelope> history) {
    for (final envelope in history) {
      _transactions[envelope.reviewEventId] = TransactionCommitted(envelope);
    }
  }

  TransactionState getTransactionState(String reviewEventId) {
    return _transactions[reviewEventId] ??
        _states[reviewEventId] ??
        TransactionRecoverable(Exception('Not found'));
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
        return existingState;
      } else {
        return TransactionFailed(
            StateError('Transaction already committed for a different language pair'));
      }
    }

    _transactions[command.reviewId] = const TransactionPending();

    final envelope = ReviewTransactionEnvelope(
      reviewEventId: command.reviewId,
      learnerContentKey: command.cardId,
      rating: command.rating.index,
      timestamp: DateTime.now(),
      languagePairKey: languagePairKey,
    );

    try {
      await commitFn(envelope);
      final committedState = TransactionCommitted(envelope);
      _transactions[command.reviewId] = committedState;
      return committedState;
    } catch (e) {
      final recoverableState = TransactionRecoverable(e);
      _transactions[command.reviewId] = recoverableState;
      return recoverableState;
    }
  }
}
