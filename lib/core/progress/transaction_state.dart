sealed class TransactionState {
  const TransactionState();
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
