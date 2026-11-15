import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/gamification/local_learning_analytics.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'test_helpers.dart';

void main() {
  group('LocalLearningAnalytics Expected Fixtures - J058', () {
    test('computes completion rate, recall accuracy and unique cards accurately', () async {
      final nowUtc = DateTime.utc(2023, 10, 15, 12, 0);
      final pairId = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');
      final pairKey = pairId.uniqueKey;
      final mockPort = StubSqliteReviewTransactionPort();

      // Card 1: Mastered
      mockPort.addCommittedReview(ReviewTransactionEnvelope(
        reviewEventId: 'evt-1', learnerContentKey: 'card-1', rating: 4,
        timestamp: nowUtc.subtract(const Duration(days: 1)), languagePairKey: pairKey,
      ));

      // Card 1: Review 2
      mockPort.addCommittedReview(ReviewTransactionEnvelope(
        reviewEventId: 'evt-2', learnerContentKey: 'card-1', rating: 3,
        timestamp: nowUtc.subtract(const Duration(days: 2)), languagePairKey: pairKey,
      ));

      // Card 2: Not mastered
      mockPort.addCommittedReview(ReviewTransactionEnvelope(
        reviewEventId: 'evt-3', learnerContentKey: 'card-2', rating: 2,
        timestamp: nowUtc.subtract(const Duration(days: 1)), languagePairKey: pairKey,
      ));

      // Card 3: Mastered
      mockPort.addCommittedReview(ReviewTransactionEnvelope(
        reviewEventId: 'evt-4', learnerContentKey: 'card-3', rating: 5,
        timestamp: nowUtc.subtract(const Duration(days: 3)), languagePairKey: pairKey,
      ));

      final result = await LocalLearningAnalytics.generateReport(
        port: mockPort,
        activePairs: [pairId],
        window: AnalyticsWindow.days7,
        nowUtc: nowUtc
      );

      expect(result, isA<AnalyticsDataState>());
      final state = result as AnalyticsDataState;
      final metrics = state.pairSpecificMetrics[pairKey]!;

      expect(metrics.totalReviews, 4);
      expect(metrics.uniqueCardsMastered, 2); // card-1, card-3

      // recall accuracy: successful / total
      // evt-1: 4 (yes), evt-2: 3 (yes), evt-3: 2 (no), evt-4: 5 (yes) -> 3 / 4 = 0.75
      expect(metrics.recallAccuracy, 0.75);

      // completion rate: mastered unique / total unique
      // total unique: 3 (card-1, card-2, card-3)
      // mastered unique: 2
      expect(metrics.completionRate, closeTo(0.666, 0.001));
    });
  });
}
