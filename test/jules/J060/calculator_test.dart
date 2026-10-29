import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/mastery_calculator.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';

void main() {
  group('MasteryCalculator J060', () {
    test('calculates domain mastery ignoring duplicates and keeping pairs separated', () {
      final reviews = [
        ReviewTransactionEnvelope(
          reviewEventId: 'evt1',
          learnerContentKey: 'card1',
          rating: 2, // good
          timestamp: DateTime(2023, 10, 1),
          languagePairKey: 'ar_de',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: 'evt2',
          learnerContentKey: 'card1',
          rating: 2,
          timestamp: DateTime(2023, 10, 2),
          languagePairKey: 'ar_de',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: 'evt2', // Duplicate event ID
          learnerContentKey: 'card1',
          rating: 3,
          timestamp: DateTime(2023, 10, 3),
          languagePairKey: 'ar_de',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: 'evt3',
          learnerContentKey: 'card1',
          rating: 2,
          timestamp: DateTime(2023, 10, 4),
          languagePairKey: 'ar_de',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: 'evt4',
          learnerContentKey: 'card2',
          rating: 2,
          timestamp: DateTime(2023, 10, 4),
          languagePairKey: 'en_de', // Wrong pair
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

      // card1 has evt1, evt2, evt3 -> 3 successful events -> mastered
      expect(projection.introducedCardCount, 1);
      expect(projection.masteredCardCount, 1);
      expect(projection.masteryPercentage, 0.2);
    });

    test('resets mastery progress on failure rating', () {
       final reviews = [
        ReviewTransactionEnvelope(reviewEventId: 'e1', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 1), languagePairKey: 'ar_de'),
        ReviewTransactionEnvelope(reviewEventId: 'e2', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 2), languagePairKey: 'ar_de'),
        ReviewTransactionEnvelope(reviewEventId: 'e3', learnerContentKey: 'c1', rating: 1, timestamp: DateTime(2023, 1, 3), languagePairKey: 'ar_de'), // hard (fails threshold)
        ReviewTransactionEnvelope(reviewEventId: 'e4', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 4), languagePairKey: 'ar_de'),
      ];

      final projection = MasteryCalculator.calculateDomainMastery(
        domainId: 'd1', sourceLanguageId: 'ar', targetLanguageId: 'de', eligibleCardCount: 1, reviews: reviews, masteryRevision: 1,
      );

      // Only 1 consecutive success after failure
      expect(projection.masteredCardCount, 0);
      expect(projection.recalledCardCount, 1);
    });
  });

  group('StreakFreezeLedger J060 boundaries', () {
    test('prevents duplicate freezes on the same local day', () {
      const ledger = StreakFreezeLedger();

      final dt1 = DateTime.utc(2023, 10, 1, 10, 0); // 10 AM UTC
      final dt2 = DateTime.utc(2023, 10, 1, 20, 0); // 8 PM UTC (same day)

      final next1 = ledger.recordUsage('missed', timestamp: dt1);
      expect(next1.remainingShields, 1);

      final next2 = next1.recordUsage('missed again', timestamp: dt2);
      expect(next2.remainingShields, 1); // Duplicate prevented
    });
  });
}
