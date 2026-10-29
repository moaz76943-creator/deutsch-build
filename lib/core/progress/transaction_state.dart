import 'review_transaction_envelope.dart';

sealed class TransactionState {}

class TransactionPending extends TransactionState {}

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
