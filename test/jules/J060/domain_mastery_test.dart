import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/domain_mastery_projection.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

void main() {
  group('DomainMasteryProjection', () {
    test('calculates mastery from verifiable review records', () {
      final events = [
        ReviewTransactionEnvelope(
          reviewEventId: 'evt_1',
          learnerContentKey: 'card_1',
          rating: 4,
          timestamp: DateTime.utc(2023, 10, 1),
          languagePairKey: 'en_de',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: 'evt_2',
          learnerContentKey: 'card_1',
          rating: 5,
          timestamp: DateTime.utc(2023, 10, 2),
          languagePairKey: 'en_de',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: 'evt_3',
          learnerContentKey: 'card_1',
          rating: 3,
          timestamp: DateTime.utc(2023, 10, 3),
          languagePairKey: 'en_de',
        ),
      ];

      final projection = DomainMasteryProjection.computeFromEvents(
        domainId: 'food',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        eligibleCardCount: 10,
        events: events,
        projectionTimeUtc: DateTime.utc(2023, 10, 4),
      );

      expect(projection.introducedCardCount, 1);
      expect(projection.recalledCardCount, 1);
      expect(projection.masteredCardCount, 1);
      expect(projection.masteryPercentage, 0.1);
      expect(projection.masteryState, DomainMasteryState.inProgress);
    });

    test('deduplicates review events and ignores invalid pairs or future dates', () {
      final events = [
        ReviewTransactionEnvelope(
          reviewEventId: 'evt_1',
          learnerContentKey: 'card_1',
          rating: 4,
          timestamp: DateTime.utc(2023, 10, 1),
          languagePairKey: 'en_de',
        ),
        // Duplicate event ID
        ReviewTransactionEnvelope(
          reviewEventId: 'evt_1',
          learnerContentKey: 'card_1',
          rating: 4,
          timestamp: DateTime.utc(2023, 10, 1),
          languagePairKey: 'en_de',
        ),
        // Wrong language pair
        ReviewTransactionEnvelope(
          reviewEventId: 'evt_2',
          learnerContentKey: 'card_2',
          rating: 4,
          timestamp: DateTime.utc(2023, 10, 1),
          languagePairKey: 'de_en',
        ),
        // Future date
        ReviewTransactionEnvelope(
          reviewEventId: 'evt_3',
          learnerContentKey: 'card_3',
          rating: 4,
          timestamp: DateTime.utc(2023, 10, 5),
          languagePairKey: 'en_de',
        ),
      ];

      final projection = DomainMasteryProjection.computeFromEvents(
        domainId: 'food',
        sourceLanguageId: 'en',
        targetLanguageId: 'de',
        eligibleCardCount: 10,
        events: events,
        projectionTimeUtc: DateTime.utc(2023, 10, 4),
      );

      expect(projection.introducedCardCount, 1);
    });

    test('rejects negative eligible card counts', () {
      expect(
        () => DomainMasteryProjection.computeFromEvents(
          domainId: 'food',
          sourceLanguageId: 'en',
          targetLanguageId: 'de',
          eligibleCardCount: -1,
          events: [],
          projectionTimeUtc: DateTime.utc(2023, 10, 4),
        ),
        throwsArgumentError,
      );
    });
  });
}
