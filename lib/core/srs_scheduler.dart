import 'progress/review_transaction_envelope.dart';

class UnifiedSrsScheduler {
  static final UnifiedSrsScheduler instance = UnifiedSrsScheduler._internal();
  UnifiedSrsScheduler._internal();

  final List<ReviewTransactionEnvelope> _inMemoryJournal = [];

  Future<void> processReviewTransaction(
      ReviewTransactionEnvelope envelope) async {
    // معالجة ذرية للحدث ومنع التكرار
    final alreadyExists = _inMemoryJournal.any(
      (e) => e.reviewEventId == envelope.reviewEventId,
    );
    if (!alreadyExists) {
      _inMemoryJournal.add(envelope);
    }
  }

  List<ReviewTransactionEnvelope> get history =>
      List.unmodifiable(_inMemoryJournal);
}
