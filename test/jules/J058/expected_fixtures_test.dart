import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/gamification/local_learning_analytics.dart';
import 'package:deutsch_bilarabi/core/srs_scheduler.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

void main() {
  group('LocalLearningAnalytics Fixture Comparison - J058', () {
    test('expected calculations correctly match actual fixtures including completion rate', () async {
      final nowUtc = DateTime.utc(2023, 11, 1, 12, 0);
      final String pair = 'fixture-pair-${DateTime.now().millisecondsSinceEpoch}';

      // Insert 4 reviews for 2 cards
      // card 1: mastered (rating 4)
      await UnifiedSrsScheduler.instance.processReviewTransaction(ReviewTransactionEnvelope(
        reviewEventId: 'fix-1',
        learnerContentKey: 'card-1',
        rating: 4,
        timestamp: DateTime.utc(2023, 10, 31, 12, 0),
        languagePairKey: pair,
      ));
      // card 1: review (rating 3)
      await UnifiedSrsScheduler.instance.processReviewTransaction(ReviewTransactionEnvelope(
        reviewEventId: 'fix-2',
        learnerContentKey: 'card-1',
        rating: 3,
        timestamp: DateTime.utc(2023, 10, 30, 12, 0),
        languagePairKey: pair,
      ));
      // card 2: review failed (rating 2)
      await UnifiedSrsScheduler.instance.processReviewTransaction(ReviewTransactionEnvelope(
        reviewEventId: 'fix-3',
        learnerContentKey: 'card-2',
        rating: 2,
        timestamp: DateTime.utc(2023, 10, 31, 10, 0),
        languagePairKey: pair,
      ));
      // card 2: review (rating 3)
      await UnifiedSrsScheduler.instance.processReviewTransaction(ReviewTransactionEnvelope(
        reviewEventId: 'fix-4',
        learnerContentKey: 'card-2',
        rating: 3,
        timestamp: DateTime.utc(2023, 10, 29, 12, 0),
        languagePairKey: pair,
      ));

      final result = await LocalLearningAnalytics.generateReport(AnalyticsWindow.days7, nowUtc: nowUtc);
      expect(result, isA<AnalyticsDataState>());

      final state = result as AnalyticsDataState;
      final metrics = state.pairSpecificMetrics[pair]!;

      expect(metrics.totalReviews, 4);
      // successful reviews (rating >= 3) = fix-1, fix-2, fix-4 (3 total)
      expect(metrics.recallAccuracy, 3 / 4);
      // unique cards: card-1, card-2 (2 total)
      // mastered cards (rating >= 4): card-1 (1 total)
      expect(metrics.uniqueCardsMastered, 1);
      expect(metrics.completionRate, 1 / 2);
    });
  });
}
