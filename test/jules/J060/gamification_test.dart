import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/domain_mastery_projection.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';
import 'package:deutsch_bilarabi/core/gamification/gamification_projection_engine.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

void main() {
  group('Gamification Projection Integrity', () {
    test('projectMastery handles replay attacks (deduplication) correctly', () {
      final events = [
        ReviewTransactionEnvelope(
          reviewEventId: '1',
          learnerContentKey: 'card1',
          rating: 2,
          timestamp: DateTime(2023, 1, 1),
          languagePairKey: 'de_ar',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: '2',
          learnerContentKey: 'card1',
          rating: 3,
          timestamp: DateTime(2023, 1, 2),
          languagePairKey: 'de_ar',
        ),
      ];

      final projection = GamificationProjectionEngine.projectMastery(
        domainId: 'domain1',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        eligibleCardCount: 1,
        events: events,
      );

      expect(projection.introducedCardCount, 1);
      expect(projection.masteredCardCount, 1); // Because the last event is rating 3
      expect(projection.masteryState, DomainMasteryState.mastered);
    });

    test('projectMastery ignores reversed pairs', () {
      final events = [
        ReviewTransactionEnvelope(
          reviewEventId: '1',
          learnerContentKey: 'card1',
          rating: 3,
          timestamp: DateTime(2023, 1, 1),
          languagePairKey: 'ar_de', // Reversed
        ),
      ];

      final projection = GamificationProjectionEngine.projectMastery(
        domainId: 'domain1',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        eligibleCardCount: 1,
        events: events,
      );

      expect(projection.introducedCardCount, 0);
      expect(projection.masteredCardCount, 0);
      expect(projection.masteryState, DomainMasteryState.available);
    });

    test('projectMastery filters invalid timestamps and negative ratings', () {
      final now = DateTime.now();
      final events = [
        ReviewTransactionEnvelope(
          reviewEventId: '1',
          learnerContentKey: 'card1',
          rating: 3,
          timestamp: now.add(const Duration(days: 2)), // Invalid future timestamp
          languagePairKey: 'de_ar',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: '2',
          learnerContentKey: 'card2',
          rating: -1, // Invalid rating
          timestamp: now.subtract(const Duration(days: 1)),
          languagePairKey: 'de_ar',
        ),
      ];

      final projection = GamificationProjectionEngine.projectMastery(
        domainId: 'domain1',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        eligibleCardCount: 2,
        events: events,
      );

      expect(projection.introducedCardCount, 0);
    });

    test('StreakFreezeLedger prevents duplicate uses on the same local day', () {
      var ledger = const StreakFreezeLedger(totalShields: 2);
      final timestamp = DateTime(2023, 1, 1, 12, 0, 0);

      ledger = ledger.recordUsage('reason1', timestamp: timestamp);
      expect(ledger.remainingShields, 1);

      ledger = ledger.recordUsage('reason2', timestamp: timestamp.add(const Duration(hours: 1)));
      expect(ledger.remainingShields, 1); // Duplicate on same local day prevented
    });

    test('projectStreak correctly applies freeze recovery and respects local days', () {
      final timestamps = [
        DateTime(2023, 1, 1, 10, 0, 0),
        DateTime(2023, 1, 1, 20, 0, 0), // Same day, deduplicated
        DateTime(2023, 1, 3, 10, 0, 0), // Gap of 1 day (Jan 2 missed)
      ];

      const ledger = StreakFreezeLedger(totalShields: 2);
      final today = DateTime(2023, 1, 4);

      final projection = GamificationProjectionEngine.projectStreak(
        activityTimestamps: timestamps,
        initialLedger: ledger,
        todayLocal: today,
      );

      expect(projection.streakCount, 3); // 1st, 2nd (freeze), 3rd. Today is 4th, not yet played.
      expect(projection.ledger.remainingShields, 1); // One freeze used for Jan 2
    });

    test('projectStreak handles broken streak after freeze exhaustion', () {
      final timestamps = [
        DateTime(2023, 1, 1, 10, 0, 0),
        DateTime(2023, 1, 5, 10, 0, 0), // Missed 2, 3, 4. Requires 3 freezes.
      ];

      const ledger = StreakFreezeLedger(totalShields: 2);
      final today = DateTime(2023, 1, 6);

      final projection = GamificationProjectionEngine.projectStreak(
        activityTimestamps: timestamps,
        initialLedger: ledger,
        todayLocal: today,
      );

      // Missed 3 days, only 2 freezes available. Streak broken on Jan 4.
      // Jan 5 starts a new streak.
      expect(projection.streakCount, 1);
      // Remaining shields should be 0 because we tried to use them
      expect(projection.ledger.remainingShields, 0);
    });

    test('DomainMasteryProjection asserts correctly', () {
      expect(() => DomainMasteryProjection(
        domainId: '1',
        sourceLanguageId: 'de',
        targetLanguageId: 'ar',
        eligibleCardCount: -1,
        introducedCardCount: 0,
        recalledCardCount: 0,
        masteredCardCount: 0,
        dueCardCount: 0,
        lastEvidenceUtc: DateTime.now(),
        masteryRevision: 0,
      ), throwsA(isA<AssertionError>()));
    });
  });
}
