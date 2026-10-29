import 'review_transaction_envelope.dart';

sealed class TransactionState {
  const TransactionState();
}

class TransactionPending extends TransactionState {
  const TransactionPending();
}

class TransactionCommitted extends TransactionState {
  final ReviewTransactionEnvelope envelope;
  TransactionCommitted(this.envelope);
}

class TransactionFailed extends TransactionState {
  final Object error;
  TransactionFailed(this.error);
}

class TransactionRecoverable extends TransactionState {
  final Object error;
  TransactionRecoverable(this.error);
}

class TransactionStatePending extends TransactionState {
  const TransactionStatePending();
}

class TransactionStateCommitted extends TransactionState {
  const TransactionStateCommitted();
}

class TransactionStateFailed extends TransactionState {
  final String reason;
  const TransactionStateFailed(this.reason);
}

class TransactionStateRecoverable extends TransactionState {
  final Object error;
  const TransactionStateRecoverable(this.error);
}
