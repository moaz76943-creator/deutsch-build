import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/domain_mastery_projection.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

void main() {
  group('DomainMasteryProjection tests', () {
    test('replay attacks: repeated events do not award duplicate points', () {
      final events = [
        ReviewTransactionEnvelope(reviewEventId: 'evt1', learnerContentKey: 'card1', rating: 3, timestamp: DateTime(2023, 10, 1), languagePairKey: 'en_es'),
        ReviewTransactionEnvelope(reviewEventId: 'evt1', learnerContentKey: 'card1', rating: 3, timestamp: DateTime(2023, 10, 1), languagePairKey: 'en_es'), // Duplicate
        ReviewTransactionEnvelope(reviewEventId: 'evt2', learnerContentKey: 'card1', rating: 3, timestamp: DateTime(2023, 10, 2), languagePairKey: 'en_es'),
        ReviewTransactionEnvelope(reviewEventId: 'evt3', learnerContentKey: 'card1', rating: 3, timestamp: DateTime(2023, 10, 3), languagePairKey: 'en_es'),
      ];

      final projection = DomainMasteryProjection.computeFromEvents(
        domainId: 'domain1',
        sourceLanguageId: 'en',
        targetLanguageId: 'es',
        eligibleCardCount: 5,
        events: events,
        projectionTimeUtc: DateTime.now().toUtc(),
      );

      // Card1 successfully reviewed 3 times (since one was deduplicated)
      expect(projection.introducedCardCount, 1);
      expect(projection.recalledCardCount, 1);
      expect(projection.masteredCardCount, 1);
    });

    test('interrupted review handling: failures reset progress', () {
      final events = [
        ReviewTransactionEnvelope(reviewEventId: 'evt1', learnerContentKey: 'card1', rating: 3, timestamp: DateTime(2023, 10, 1), languagePairKey: 'en_es'),
        ReviewTransactionEnvelope(reviewEventId: 'evt2', learnerContentKey: 'card1', rating: 1, timestamp: DateTime(2023, 10, 2), languagePairKey: 'en_es'), // Failure
        ReviewTransactionEnvelope(reviewEventId: 'evt3', learnerContentKey: 'card1', rating: 3, timestamp: DateTime(2023, 10, 3), languagePairKey: 'en_es'),
        ReviewTransactionEnvelope(reviewEventId: 'evt4', learnerContentKey: 'card1', rating: 3, timestamp: DateTime(2023, 10, 4), languagePairKey: 'en_es'),
      ];

      final projection = DomainMasteryProjection.computeFromEvents(
        domainId: 'domain1',
        sourceLanguageId: 'en',
        targetLanguageId: 'es',
        eligibleCardCount: 5,
        events: events,
        projectionTimeUtc: DateTime.now().toUtc(),
      );

      // Card1 failed on evt2, so progress reset. Only 2 successful reviews follow.
      expect(projection.introducedCardCount, 1);
      expect(projection.recalledCardCount, 1); // it was recalled (count > 0)
      expect(projection.masteredCardCount, 0); // threshold (3) not met
    });

    test('reversed pairs do not leak mastery', () {
      final events = [
        ReviewTransactionEnvelope(reviewEventId: 'evt1', learnerContentKey: 'card1', rating: 3, timestamp: DateTime(2023, 10, 1), languagePairKey: 'es_en'),
        ReviewTransactionEnvelope(reviewEventId: 'evt2', learnerContentKey: 'card1', rating: 3, timestamp: DateTime(2023, 10, 2), languagePairKey: 'es_en'),
        ReviewTransactionEnvelope(reviewEventId: 'evt3', learnerContentKey: 'card1', rating: 3, timestamp: DateTime(2023, 10, 3), languagePairKey: 'es_en'),
      ];

      final projection = DomainMasteryProjection.computeFromEvents(
        domainId: 'domain1',
        sourceLanguageId: 'en', // Looking for en_es
        targetLanguageId: 'es',
        eligibleCardCount: 5,
        events: events,
        projectionTimeUtc: DateTime.now().toUtc(),
      );

      expect(projection.introducedCardCount, 0);
      expect(projection.recalledCardCount, 0);
      expect(projection.masteredCardCount, 0);
    });

    test('invalid timestamps (future) are ignored', () {
      final futureDate = DateTime.now().toUtc().add(const Duration(days: 10));
      final events = [
        ReviewTransactionEnvelope(reviewEventId: 'evt1', learnerContentKey: 'card1', rating: 3, timestamp: futureDate, languagePairKey: 'en_es'),
      ];

      final projection = DomainMasteryProjection.computeFromEvents(
        domainId: 'domain1',
        sourceLanguageId: 'en',
        targetLanguageId: 'es',
        eligibleCardCount: 5,
        events: events,
        projectionTimeUtc: DateTime.now().toUtc(),
      );

      expect(projection.introducedCardCount, 0);
    });
  });

  group('StreakFreezeLedger tests', () {
    test('repeated freeze prevention on the same day', () {
      const ledger = StreakFreezeLedger();
      final dt = DateTime(2023, 1, 1, 12, 0);

      final l1 = ledger.recordUsage('miss', timestamp: dt);
      final l2 = l1.recordUsage('miss', timestamp: dt.add(const Duration(hours: 1)));

      expect(l1.remainingShields, 1);
      expect(l2.remainingShields, 1); // Should not consume another
    });

    test('freeze consumption on different days', () {
      const ledger = StreakFreezeLedger();
      final dt1 = DateTime(2023, 1, 1, 12, 0);
      final dt2 = DateTime(2023, 1, 2, 12, 0);
      final dt3 = DateTime(2023, 1, 3, 12, 0);

      final l1 = ledger.recordUsage('miss1', timestamp: dt1);
      expect(l1.remainingShields, 1);

      final l2 = l1.recordUsage('miss2', timestamp: dt2);
      expect(l2.remainingShields, 0);

      final l3 = l2.recordUsage('miss3', timestamp: dt3);
      expect(l3.remainingShields, 0); // Out of shields
    });
  });
}
