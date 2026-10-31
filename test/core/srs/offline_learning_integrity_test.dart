import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';
import 'package:deutsch_bilarabi/core/srs/spaced_repetition_engine.dart';
import 'package:deutsch_bilarabi/core/srs/leitner_box_state.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_manager.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_persistence_port.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

class FakeAtomicStore implements TransactionPersistencePort {
  final Map<String, ReviewCommand> applied = {};
  int advances = 0;
  bool failBefore = false;
  bool failAfter = false;

  @override
  Future<TransactionCommitOutcome> commitReviewAtomically({
    required ReviewCommand command,
    required ReviewTransactionEnvelope envelope,
  }) async {
    if (failBefore) throw StateError('interrupted before commit');
    final prior = applied[command.reviewId];
    if (prior != null) {
      if (prior.cardId != command.cardId ||
          prior.sourceLanguageId != command.sourceLanguageId ||
          prior.targetLanguageId != command.targetLanguageId ||
          prior.facetKey != command.facetKey ||
          prior.pairEpoch != command.pairEpoch ||
          prior.rating != command.rating ||
          prior.hinted != command.hinted) {
        throw StateError('conflicting duplicate');
      }
      return TransactionCommitOutcome.alreadyCommitted;
    }
    expect(envelope.languagePairKey,
        command.sourceLanguageId + '_' + command.targetLanguageId);
    applied[command.reviewId] = command;
    advances++;
    if (failAfter) throw StateError('acknowledgment lost after commit');
    return TransactionCommitOutcome.applied;
  }
}

ReviewCommand command({String id = 'r1', String src = 'de',
    String dst = 'ar', String card = 'c1'}) => ReviewCommand(
  reviewId: id, sourceLanguageId: src, targetLanguageId: dst,
  cardId: card, facetKey: 'word', pairEpoch: 7,
  rating: ReviewRating.good, hinted: false,
);

void main() {
  group('offline atomic review contract', () {
    test('manager recreation + replay do not advance twice', () async {
      final store = FakeAtomicStore();
      expect(await ReviewTransactionManager(store).processTransaction(command()),
          TransactionCommitOutcome.applied);
      expect(await ReviewTransactionManager(store).processTransaction(command()),
          TransactionCommitOutcome.alreadyCommitted);
      expect(store.advances, 1);
    });
    test('interrupted before commit can retry', () async {
      final store = FakeAtomicStore()..failBefore = true;
      final manager = ReviewTransactionManager(store);
      await expectLater(manager.processTransaction(command()), throwsStateError);
      expect(store.advances, 0);
      store.failBefore = false;
      expect(await manager.processTransaction(command()), TransactionCommitOutcome.applied);
      expect(store.advances, 1);
    });
    test('lost commit acknowledgment must not double advance', () async {
      final store = FakeAtomicStore()..failAfter = true;
      final manager = ReviewTransactionManager(store);
      await expectLater(manager.processTransaction(command()), throwsStateError);
      expect(store.advances, 1);
      store.failAfter = false;
      expect(await manager.processTransaction(command()),
          TransactionCommitOutcome.alreadyCommitted);
      expect(store.advances, 1);
    });
    test('pair collision cannot reuse an event ID', () async {
      final store = FakeAtomicStore();
      final manager = ReviewTransactionManager(store);
      await manager.processTransaction(command());
      await expectLater(manager.processTransaction(command(src: 'ar', dst: 'de')),
          throwsStateError);
      expect(store.advances, 1);
    });
    test('invalid pair and malformed card are rejected', () async {
      final store = FakeAtomicStore();
      final manager = ReviewTransactionManager(store);
      await expectLater(manager.processTransaction(command(src: 'de', dst: 'de')),
          throwsArgumentError);
      await expectLater(manager.processTransaction(command(card: '  ')),
          throwsArgumentError);
      expect(store.advances, 0);
    });
  });

  group('reproducible bounded SRS', () {
    test('injected clock gives deterministic due date', () {
      final now = DateTime.utc(2026, 10, 13);
      final result = ProductionSrsEngine.processReview(
        currentIntervalDays: 6, currentEaseFactor: 2.5,
        currentRepetitions: 2, rating: SrsRating.good, currentTime: now,
      );
      expect(result.nextIntervalDays, 15);
      expect(result.repetitionCount, 3);
      expect(result.nextReviewDate, now.add(const Duration(days: 15)));
    });
    test('nonfinite numbers are rejected', () {
      for (final bad in [double.nan, double.infinity, double.negativeInfinity]) {
        expect(() => ProductionSrsEngine.processReview(
          currentIntervalDays: 5, currentEaseFactor: bad,
          currentRepetitions: 2, rating: SrsRating.good,
        ), throwsArgumentError);
        expect(() => ProductionSrsEngine.processReview(
          currentIntervalDays: 5, currentEaseFactor: 2.5,
          currentRepetitions: 2, rating: SrsRating.good,
          morphologicalMultiplier: bad,
        ), throwsArgumentError);
      }
    });
    test('corrupt counters and invalid ratings are rejected', () {
      final state = LeitnerCardState(cardId: 'c1', currentBox: LeitnerBox.box1,
          lastReviewedEpoch: 0, nextReviewEpoch: 0);
      expect(() => ProductionSrsEngine.processReview(
        currentIntervalDays: 1, currentEaseFactor: 2.0,
        currentRepetitions: -1, rating: SrsRating.good,
      ), throwsArgumentError);
      expect(() => SpacedRepetitionEngine.calculateNextInterval(
        previousState: state, rating: 5,
      ), throwsArgumentError);
    });
    test('Leitner clock and ease are bounded', () {
      const now = 1704067200000;
      final state = LeitnerCardState(cardId: 'c1', currentBox: LeitnerBox.box4,
        lastReviewedEpoch: now - 86400000, nextReviewEpoch: now,
        easeFactor: 2.9);
      expect(state.isDueAt(now), isTrue);
      final next = SpacedRepetitionEngine.calculateNextInterval(
        previousState: state, rating: 3, currentTimeEpoch: now,
      );
      expect(next.currentBox, LeitnerBox.box5);
      expect(next.easeFactor, 3.0);
      expect(next.lastReviewedEpoch, now);
    });
  });
}
