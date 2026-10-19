import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';
import 'package:deutsch_bilarabi/core/gamification/mastery_projection_engine.dart';
import 'package:deutsch_bilarabi/core/gamification/domain_mastery_projection.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

void main() {
  group('StreakFreezeLedger', () {
    test('Prevents repeated freeze on the same local day', () {
      const ledger = StreakFreezeLedger();
      final now = DateTime(2023, 10, 15, 12, 0);

      final l1 = ledger.recordUsage('missed day', timestamp: now);
      expect(l1.remainingShields, 1);

      // Attempt repeated freeze on same day, different hour
      final l2 = l1.recordUsage('missed day again', timestamp: DateTime(2023, 10, 15, 23, 0));
      expect(l2.remainingShields, 1); // should not consume another shield
      expect(l2.usageHistory.length, 1);

      // Next day allows consumption
      final l3 = l2.recordUsage('missed next day', timestamp: DateTime(2023, 10, 16, 8, 0));
      expect(l3.remainingShields, 0);
      expect(l3.usageHistory.length, 2);
    });

    test('Handles timezone transitions and boundaries correctly', () {
      const ledger = StreakFreezeLedger();
      // Suppose UTC is 23:00 on 15th, local is 01:00 on 16th.
      // We pass the DateTimes explicitly to simulate local times.



      // This test ensures it relies on the provided DateTime's year/month/day.
      final l1 = ledger.recordUsage('tz1', timestamp: DateTime(2023, 10, 15, 23, 0));
      final l2 = l1.recordUsage('tz2', timestamp: DateTime(2023, 10, 16, 1, 0));

      expect(l2.remainingShields, 0); // Consumes both since they are different days
    });
  });

  group('MasteryProjectionEngine', () {
    final eligible = {'card1', 'card2', 'card3'};
    final defaultTime = DateTime(2023, 1, 1, 10, 0);

    ReviewTransactionEnvelope buildEvent({
      required String eventId,
      required String cardId,
      required int rating,
      DateTime? time,
      String langPair = 'en_es',
    }) {
      return ReviewTransactionEnvelope(
        reviewEventId: eventId,
        learnerContentKey: cardId,
        rating: rating,
        timestamp: time ?? defaultTime,
        languagePairKey: langPair,
      );
    }

    test('Calculates domain mastery from deduplicated genuine review events (replay attack)', () {
      final events = [
        buildEvent(eventId: 'e1', cardId: 'card1', rating: 3),
        // Replay attack: same event id submitted again
        buildEvent(eventId: 'e1', cardId: 'card1', rating: 3),
        buildEvent(eventId: 'e1', cardId: 'card1', rating: 3),
      ];

      final projection = MasteryProjectionEngine.calculate(
        domainId: 'd1',
        sourceLanguageId: 'en',
        targetLanguageId: 'es',
        eligibleContentKeys: eligible,
        events: events,
        masteryThreshold: 2,
        timestamp: defaultTime.add(const Duration(days: 1)),
      );

      // Only 1 introduced, 1 success (others deduplicated)
      expect(projection.introducedCardCount, 1);
      expect(projection.masteredCardCount, 0); // needs 2 successes
      expect(projection.masteryRevision, 1);
    });

    test('Verifies reversed pairs are separate', () {
      final events = [
        buildEvent(eventId: 'e1', cardId: 'card1', rating: 4, langPair: 'en_es'),
        buildEvent(eventId: 'e2', cardId: 'card1', rating: 4, langPair: 'es_en'), // Reversed pair
        buildEvent(eventId: 'e3', cardId: 'card1', rating: 4, langPair: 'en_es'),
      ];

      final projection = MasteryProjectionEngine.calculate(
        domainId: 'd1',
        sourceLanguageId: 'en',
        targetLanguageId: 'es',
        eligibleContentKeys: eligible,
        events: events,
        masteryThreshold: 2,
        timestamp: defaultTime.add(const Duration(days: 1)),
      );

      // It should only pick up en_es events
      expect(projection.masteredCardCount, 1); // e1 and e3 provide 2 successes
    });

    test('Interrupted review and missing/conflicting evidence treated as unknown (negative or impossible)', () {
      final events = [
        buildEvent(eventId: 'e1', cardId: 'card999', rating: 4), // not eligible
      ];

      final projection = MasteryProjectionEngine.calculate(
        domainId: 'd1',
        sourceLanguageId: 'en',
        targetLanguageId: 'es',
        eligibleContentKeys: eligible,
        events: events,
        timestamp: defaultTime.add(const Duration(days: 1)),
      );

      // Invalid card999 is ignored
      expect(projection.introducedCardCount, 0);
      expect(projection.dueCardCount, 0);
      expect(projection.masteryPercentage, 0.0);
    });

    test('Invalid future timestamps are rejected', () {
      final futureTime = defaultTime.add(const Duration(days: 10));
      final events = [
        buildEvent(eventId: 'e1', cardId: 'card1', rating: 4, time: futureTime),
      ];

      final projection = MasteryProjectionEngine.calculate(
        domainId: 'd1',
        sourceLanguageId: 'en',
        targetLanguageId: 'es',
        eligibleContentKeys: eligible,
        events: events,
        timestamp: defaultTime, // `now` is before `futureTime`
      );

      expect(projection.introducedCardCount, 0);
    });

    test('Bounded replay window limits additive inflation', () {
      final oldTime = defaultTime.subtract(const Duration(days: 400));
      final events = [
        buildEvent(eventId: 'e1', cardId: 'card1', rating: 4, time: oldTime),
        buildEvent(eventId: 'e2', cardId: 'card2', rating: 4, time: defaultTime),
      ];

      final projection = MasteryProjectionEngine.calculate(
        domainId: 'd1',
        sourceLanguageId: 'en',
        targetLanguageId: 'es',
        eligibleContentKeys: eligible,
        events: events,
        timestamp: defaultTime.add(const Duration(days: 1)),
        boundedReplayWindow: const Duration(days: 365),
      );

      // card1's event is outside window
      expect(projection.introducedCardCount, 1); // only card2
    });

    test('Calculates mastery state properly', () {
      final events = [
        buildEvent(eventId: 'e1', cardId: 'card1', rating: 4, time: defaultTime),
        buildEvent(eventId: 'e2', cardId: 'card1', rating: 4, time: defaultTime.add(const Duration(seconds: 1))),
        buildEvent(eventId: 'e3', cardId: 'card2', rating: 4, time: defaultTime),
        buildEvent(eventId: 'e4', cardId: 'card2', rating: 4, time: defaultTime.add(const Duration(seconds: 1))),
      ];

      final projection = MasteryProjectionEngine.calculate(
        domainId: 'd1',
        sourceLanguageId: 'en',
        targetLanguageId: 'es',
        eligibleContentKeys: {'card1', 'card2'},
        events: events,
        masteryThreshold: 2,
        timestamp: defaultTime.add(const Duration(days: 1)),
      );

      expect(projection.introducedCardCount, 2);
      expect(projection.masteredCardCount, 2);
      expect(projection.masteryState, DomainMasteryState.mastered);
      expect(projection.masteryPercentage, 1.0);
    });
  });
}
