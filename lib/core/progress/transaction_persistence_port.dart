import 'review_transaction_envelope.dart';
import 'transaction_state.dart';

abstract interface class TransactionPersistencePort {
  Future<TransactionState?> getTransactionState(String reviewEventId);
  Future<ReviewTransactionEnvelope?> getTransactionEnvelope(String reviewEventId);
  Future<void> saveTransaction(ReviewTransactionEnvelope envelope, TransactionState state);
  Future<void> updateTransactionState(String reviewEventId, TransactionState state);
}
