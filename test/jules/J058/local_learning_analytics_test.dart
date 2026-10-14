import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/gamification/local_learning_analytics.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

void main() {
  group('LocalLearningAnalytics', () {
    test('returns correct analytics for valid test data', () async {
      final now = DateTime.utc(2023, 10, 15);
      final testHistory = [
        ReviewTransactionEnvelope(
          reviewEventId: '1',
          learnerContentKey: 'card1',
          rating: 4,
          timestamp: now.subtract(const Duration(days: 1)),
          languagePairKey: 'de-ar',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: '2',
          learnerContentKey: 'card2',
          rating: 2,
          timestamp: now.subtract(const Duration(days: 2)),
          languagePairKey: 'de-ar',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: '3',
          learnerContentKey: 'card3',
          rating: 3,
          timestamp: now.subtract(const Duration(days: 16)), // Half window is 15
          languagePairKey: 'de-ar',
        ),
      ];

      final state = await LocalLearningAnalytics.analyze(
        languagePairKey: 'de-ar',
        daysWindow: 30,
        currentTime: now,
        testHistory: testHistory,
      );

      expect(state, isA<AnalyticsData>());
      final data = state as AnalyticsData;
      expect(data.totalReviews, 3);
      expect(data.recallAccuracy, closeTo(2 / 3, 0.01)); // ratings >= 3 are correct
      expect(data.learningTrend, 'upward'); // h2 = 2, h1 = 1.  2 > 1 * 1.1 -> upward
      expect(data.masteredCards, 1); // card1
    });

    test('deduplicates review events and isolates by language pair', () async {
      final now = DateTime.utc(2023, 10, 15);
      final testHistory = [
        ReviewTransactionEnvelope(
          reviewEventId: '1',
          learnerContentKey: 'card1',
          rating: 4,
          timestamp: now.subtract(const Duration(days: 1)),
          languagePairKey: 'de-ar',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: '1', // duplicate
          learnerContentKey: 'card1',
          rating: 4,
          timestamp: now.subtract(const Duration(days: 1)),
          languagePairKey: 'de-ar',
        ),
        ReviewTransactionEnvelope(
          reviewEventId: '3',
          learnerContentKey: 'card3',
          rating: 4,
          timestamp: now.subtract(const Duration(days: 1)),
          languagePairKey: 'en-ar', // different language pair
        ),
      ];

      final state = await LocalLearningAnalytics.analyze(
        languagePairKey: 'de-ar',
        daysWindow: 30,
        currentTime: now,
        testHistory: testHistory,
      );

      expect(state, isA<AnalyticsData>());
      final data = state as AnalyticsData;
      expect(data.totalReviews, 1);
    });

    test('handles empty data gracefully', () async {
      final state = await LocalLearningAnalytics.analyze(
        languagePairKey: 'de-ar',
        daysWindow: 30,
        testHistory: [],
      );

      expect(state, isA<AnalyticsData>());
      final data = state as AnalyticsData;
      expect(data.totalReviews, 0);
      expect(data.recallAccuracy, 0.0);
      expect(data.completionRate, 0.0);
      expect(data.learningTrend, 'flat');
      expect(data.masteredCards, 0);
    });

    test('handles corrupted records gracefully', () async {
      final now = DateTime.utc(2023, 10, 15);
      final state = await LocalLearningAnalytics.analyze(
        languagePairKey: 'de-ar',
        daysWindow: 30,
        currentTime: now,
        testHistory: [
          ReviewTransactionEnvelope(
            reviewEventId: '', // invalid ID
            learnerContentKey: 'card1',
            rating: 4,
            timestamp: now.subtract(const Duration(days: 1)),
            languagePairKey: 'de-ar',
          ),
        ],
      );

      expect(state, isA<AnalyticsData>());
      final data = state as AnalyticsData;
      expect(data.totalReviews, 0); // Excluded due to empty ID
    });
  });
}
