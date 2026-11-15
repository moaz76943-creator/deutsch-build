import 'package:deutsch_bilarabi/core/progress/sqlite_review_transaction_port.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_persistence_port.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'package:sqflite/sqflite.dart';

class StubSqliteReviewTransactionPort implements SqliteReviewTransactionPort {
  Map<String, List<ReviewTransactionEnvelope>> _data = {};

  void stubReadCommittedReviews(String pairKey, List<ReviewTransactionEnvelope> envelopes) {
    _data[pairKey] = envelopes;
  }

  void addCommittedReview(ReviewTransactionEnvelope envelope) {
    _data.putIfAbsent(envelope.languagePairKey, () => []).add(envelope);
  }

  @override
  Future<List<ReviewTransactionEnvelope>> readCommittedReviews({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String semanticVersion,
    int limit = 50000,
  }) async {
    final key = '${sourceLanguageId}_${targetLanguageId}_$semanticVersion';
    return _data[key] ?? [];
  }

  @override
  AtomicReviewMutation get applyReview => throw UnimplementedError();

  @override
  Future<ReviewCommitResult> commitOnce({required ReviewCommand command, required ReviewTransactionEnvelope envelope}) {
    throw UnimplementedError();
  }

  @override
  Database get database => throw UnimplementedError();
}
