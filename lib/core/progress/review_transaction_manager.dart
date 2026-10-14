import 'review_transaction_envelope.dart';
import 'transaction_state.dart';

typedef PersistenceHandler = Future<void> Function(ReviewTransactionEnvelope envelope);

class ReviewTransactionManager {
  final PersistenceHandler persistenceHandler;
  final Map<String, TransactionState> _states = {};
  final Map<String, ReviewTransactionEnvelope> _envelopes = {};

  ReviewTransactionManager({required this.persistenceHandler});

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
      await persistenceHandler(envelope);
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
}
