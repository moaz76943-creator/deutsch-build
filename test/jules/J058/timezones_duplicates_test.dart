import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/gamification/local_learning_analytics.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'test_helpers.dart';

void main() {
  group('LocalLearningAnalytics Timezones and Duplicates - J058', () {
    test('aggregates correctly and handles timezone boundaries, duplicates, and pair switching', () async {
      final nowUtc = DateTime.utc(2023, 10, 15, 12, 0);

      final pair1Id = DirectedPairId(sourceLocale: 'de', targetLocale: 'en', semanticVersion: '1.0.0');
      final pair2Id = DirectedPairId(sourceLocale: 'fr', targetLocale: 'en', semanticVersion: '1.0.0');
      final pair1 = pair1Id.uniqueKey;
      final pair2 = pair2Id.uniqueKey;

      final mockPort = StubSqliteReviewTransactionPort();

      mockPort.addCommittedReview(ReviewTransactionEnvelope(
        reviewEventId: 'evt-1-$pair1', learnerContentKey: 'card-a', rating: 3,
        timestamp: DateTime.utc(2023, 10, 15, 1, 0), languagePairKey: pair1,
      ));

      // duplicate id
      mockPort.addCommittedReview(ReviewTransactionEnvelope(
        reviewEventId: 'evt-1-$pair1', learnerContentKey: 'card-a', rating: 4,
        timestamp: DateTime.utc(2023, 10, 15, 2, 0), languagePairKey: pair1,
      ));

      mockPort.addCommittedReview(ReviewTransactionEnvelope(
        reviewEventId: 'evt-2-$pair1', learnerContentKey: 'card-b', rating: 4,
        timestamp: DateTime.utc(2023, 10, 14, 23, 0), languagePairKey: pair1,
      ));

      mockPort.addCommittedReview(ReviewTransactionEnvelope(
        reviewEventId: 'evt-3-$pair2', learnerContentKey: 'card-c', rating: 2,
        timestamp: DateTime.utc(2023, 10, 10, 12, 0), languagePairKey: pair2,
      ));

      mockPort.addCommittedReview(ReviewTransactionEnvelope(
        reviewEventId: 'evt-old-$pair1', learnerContentKey: 'card-d', rating: 5,
        timestamp: DateTime.utc(2023, 10, 1, 12, 0), languagePairKey: pair1,
      ));

      final result7Days = await LocalLearningAnalytics.generateReport(
        port: mockPort,
        activePairs: [pair1Id, pair2Id],
        window: AnalyticsWindow.days7,
        nowUtc: nowUtc
      );

      expect(result7Days, isA<AnalyticsDataState>());

      final state = result7Days as AnalyticsDataState;
      final deEnMetrics = state.pairSpecificMetrics[pair1]!;
      expect(deEnMetrics.totalReviews, 2);
      expect(deEnMetrics.uniqueCardsMastered, 1);
      expect(deEnMetrics.recallAccuracy, 1.0);
      expect(deEnMetrics.dailyReviews, {
        '2023-10-15': 1,
        '2023-10-14': 1,
      });

      final frEnMetrics = state.pairSpecificMetrics[pair2]!;
      expect(frEnMetrics.totalReviews, 1);
      expect(frEnMetrics.uniqueCardsMastered, 0);
      expect(frEnMetrics.recallAccuracy, 0.0);
      expect(frEnMetrics.dailyReviews, {
        '2023-10-10': 1,
      });

      final result30Days = await LocalLearningAnalytics.generateReport(
        port: mockPort,
        activePairs: [pair1Id, pair2Id],
        window: AnalyticsWindow.days30,
        nowUtc: nowUtc
      );

      final state30 = result30Days as AnalyticsDataState;
      final deEnMetrics30 = state30.pairSpecificMetrics[pair1]!;

      expect(deEnMetrics30.totalReviews, 3);
      expect(deEnMetrics30.uniqueCardsMastered, 2);
    });
  });
}
