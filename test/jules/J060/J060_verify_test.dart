import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/mastery_calculator.dart';
import 'package:deutsch_bilarabi/core/gamification/domain_mastery_projection.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';

void main() {
  group('Mastery Projection J060 tests', () {
    test('treat missing or conflicting review evidence as unknown', () {
      final reviews = [
        ReviewTransactionEnvelope(
          reviewEventId: 'evt1',
          learnerContentKey: 'card1',
          rating: 2,
          timestamp: DateTime(2023, 10, 1),
          languagePairKey: 'ar_de',
        ),
      ];

      final projection = MasteryCalculator.calculateDomainMastery(
        domainId: 'domain1',
        sourceLanguageId: 'ar',
        targetLanguageId: 'de',
        eligibleCardCount: 5,
        reviews: reviews,
        masteryRevision: 1,
      );

      // It hasn't reached mastery yet
      expect(projection.masteredCardCount, 0);
      expect(projection.recalledCardCount, 1);

      // Since evidence is not enough to master, it remains "unknown" or "in progress"
      expect(projection.masteryState, DomainMasteryState.inProgress);
    });

    test('replay attacks: repeated events do not award duplicate points', () {
       final reviews = [
        ReviewTransactionEnvelope(reviewEventId: 'e1', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 1), languagePairKey: 'ar_de'),
        ReviewTransactionEnvelope(reviewEventId: 'e1', learnerContentKey: 'c1', rating: 3, timestamp: DateTime(2023, 1, 1), languagePairKey: 'ar_de'),
        ReviewTransactionEnvelope(reviewEventId: 'e1', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 1), languagePairKey: 'ar_de'),
      ];

      final projection = MasteryCalculator.calculateDomainMastery(
        domainId: 'domain1',
        sourceLanguageId: 'ar',
        targetLanguageId: 'de',
        eligibleCardCount: 5,
        reviews: reviews,
        masteryRevision: 1,
      );

      // Only 1 successful event because of deduplication
      expect(projection.masteredCardCount, 0);
      expect(projection.recalledCardCount, 1);
    });

    test('interrupted review handling', () {
       final reviews = [
        ReviewTransactionEnvelope(reviewEventId: 'e1', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 1), languagePairKey: 'ar_de'),
        // Gap of time, then another review
        ReviewTransactionEnvelope(reviewEventId: 'e2', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 10), languagePairKey: 'ar_de'),
        ReviewTransactionEnvelope(reviewEventId: 'e3', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 20), languagePairKey: 'ar_de'),
      ];

      final projection = MasteryCalculator.calculateDomainMastery(
        domainId: 'domain1',
        sourceLanguageId: 'ar',
        targetLanguageId: 'de',
        eligibleCardCount: 5,
        reviews: reviews,
        masteryRevision: 1,
      );

      // 3 successful events -> mastered
      expect(projection.masteredCardCount, 1);
    });

    test('reversed pairs do not leak mastery', () {
      final reviews = [
        ReviewTransactionEnvelope(reviewEventId: 'e1', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 1), languagePairKey: 'de_ar'),
        ReviewTransactionEnvelope(reviewEventId: 'e2', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 2), languagePairKey: 'de_ar'),
        ReviewTransactionEnvelope(reviewEventId: 'e3', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 3), languagePairKey: 'de_ar'),
      ];

      final projection = MasteryCalculator.calculateDomainMastery(
        domainId: 'domain1',
        sourceLanguageId: 'ar', // target is ar_de, but events are de_ar
        targetLanguageId: 'de',
        eligibleCardCount: 5,
        reviews: reviews,
        masteryRevision: 1,
      );

      expect(projection.masteredCardCount, 0);
      expect(projection.introducedCardCount, 0);
    });
  });

  group('StreakFreezeLedger replay and repeated freeze tests', () {
    test('repeated freeze prevention', () {
      const ledger = StreakFreezeLedger();
      final dt = DateTime(2023, 1, 1, 12, 0);

      final l1 = ledger.recordUsage('miss', timestamp: dt);
      final l2 = l1.recordUsage('miss', timestamp: dt.add(const Duration(hours: 1)));

      expect(l1.remainingShields, 1);
      expect(l2.remainingShields, 1); // Should not consume another
    });

    test('freeze consumption', () {
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
