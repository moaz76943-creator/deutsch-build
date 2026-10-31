import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_persistence_port.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

/// Fake of one atomic local commit; real SQLite implementation is still
/// required before the feature can claim process-death durability.
class AtomicFakePort implements TransactionPersistencePort {
  final Map<String, ReviewCommand> journal = {};
  final Map<String, int> pairAdvances = {};
  bool failBeforeCommit = false;

  @override
  Future<ReviewCommitResult> commitOnce({
    required ReviewCommand command,
    required ReviewTransactionEnvelope envelope,
  }) async {
    if (failBeforeCommit) throw StateError('injected rollback');
    final existing = journal[command.reviewId];
    if (existing != null) {
      if (!existing.samePayloadAs(command)) {
        throw StateError('conflicting reviewId payload');
      }
      return ReviewCommitResult.alreadyCommitted;
    }
    journal[command.reviewId] = command;
    pairAdvances[envelope.languagePairKey] =
        (pairAdvances[envelope.languagePairKey] ?? 0) + 1;
    return ReviewCommitResult.committed;
  }
}

ReviewCommand review(String id, {String source = 'de', String target = 'ar'}) =>
    ReviewCommand(
      reviewId: id,
      sourceLanguageId: source,
      targetLanguageId: target,
      semanticVersion: 'v2',
      cardId: 'card',
      facetKey: 'lexeme',
      pairEpoch: 7,
      rating: ReviewRating.good,
      hinted: false,
    );

void main() {
  final stamp = DateTime.utc(2026, 10, 13);
  test('repeat event and manager restart advance exactly once', () async {
    final port = AtomicFakePort();
    final manager = ReviewTransactionManager(port, clock: () => stamp);
    expect(await manager.processTransaction(review('r1')), ReviewCommitResult.committed);
    final restarted = ReviewTransactionManager(port, clock: () => stamp);
    expect(await restarted.processTransaction(review('r1')),
        ReviewCommitResult.alreadyCommitted);
    expect(port.pairAdvances['de_ar_v2'], 1);
  });

  test('rollback before commit is recoverable without advancing', () async {
    final port = AtomicFakePort()..failBeforeCommit = true;
    final manager = ReviewTransactionManager(port, clock: () => stamp);
    await expectLater(manager.processTransaction(review('r1')), throwsStateError);
    expect(port.pairAdvances, isEmpty);
    port.failBeforeCommit = false;
    expect(await manager.processTransaction(review('r1')), ReviewCommitResult.committed);
    expect(port.pairAdvances['de_ar_v2'], 1);
  });

  test('same event ID with a different pair is not silently replayed', () async {
    final port = AtomicFakePort();
    final manager = ReviewTransactionManager(port, clock: () => stamp);
    await manager.processTransaction(review('r1'));
    await expectLater(
      manager.processTransaction(review('r1', source: 'ar', target: 'de')),
      throwsStateError,
    );
    expect(port.pairAdvances['ar_de_v2'], isNull);
  });

  test('distinct direction is isolated even for identical card', () async {
    final port = AtomicFakePort();
    final manager = ReviewTransactionManager(port, clock: () => stamp);
    await manager.processTransaction(review('r1'));
    await manager.processTransaction(review('r2', source: 'ar', target: 'de'));
    expect(port.pairAdvances['de_ar_v2'], 1);
    expect(port.pairAdvances['ar_de_v2'], 1);
  });

  test('malformed review and reflexive pair fail before storage', () async {
    final port = AtomicFakePort();
    final manager = ReviewTransactionManager(port, clock: () => stamp);
    await expectLater(
      manager.processTransaction(review('', source: 'de', target: 'de')),
      throwsArgumentError,
    );
    expect(port.journal, isEmpty);
  });
}
