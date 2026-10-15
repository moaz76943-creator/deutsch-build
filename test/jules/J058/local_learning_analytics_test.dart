import 'package:flutter_test/flutter_test.dart';
import '../../../lib/features/gamification/local_learning_analytics.dart';

void main() {
  group('LocalLearningAnalytics', () {
    final nowString = '2023-10-15T12:00:00Z';
    final nowUtc = DateTime.parse(nowString).toUtc();

    test('returns LocalAnalyticsUnavailable when history is empty', () async {
      final result = await LocalLearningAnalytics.generateReport(
        testHistory: [],
        testNowUtc: nowString,
      );

      expect(result, isA<LocalAnalyticsUnavailable>());
    });

    test('ignores records outside the time window', () async {
      final history = [
        {
          'reviewEventId': '1',
          'learnerContentKey': 'key1',
          'rating': 3,
          'timestamp': nowUtc.subtract(const Duration(days: 5)).toIso8601String(),
          'languagePairKey': 'en-ar',
        },
        {
          'reviewEventId': '2',
          'learnerContentKey': 'key2',
          'rating': 2,
          'timestamp': nowUtc.subtract(const Duration(days: 35)).toIso8601String(), // Outside 30 days
          'languagePairKey': 'en-ar',
        },
      ];

      final result = await LocalLearningAnalytics.generateReport(
        testHistory: history,
        testNowUtc: nowString,
        window: AnalyticsWindow.days30,
      );

      expect(result, isA<LocalAnalyticsData>());
      final data = result as LocalAnalyticsData;
      expect(data.totalReviews, 1);
    });

    test('deduplicates repeating events', () async {
       final history = [
        {
          'reviewEventId': '1',
          'learnerContentKey': 'key1',
          'rating': 3,
          'timestamp': nowUtc.subtract(const Duration(days: 5)).toIso8601String(),
          'languagePairKey': 'en-ar',
        },
        {
          'reviewEventId': '1', // Duplicate
          'learnerContentKey': 'key1',
          'rating': 3,
          'timestamp': nowUtc.subtract(const Duration(days: 5)).toIso8601String(),
          'languagePairKey': 'en-ar',
        },
      ];

      final result = await LocalLearningAnalytics.generateReport(
        testHistory: history,
        testNowUtc: nowString,
      );

      final data = result as LocalAnalyticsData;
      expect(data.totalReviews, 1);
    });

    test('isolates pair-specific metrics', () async {
      final history = [
        {
          'reviewEventId': '1',
          'learnerContentKey': 'key1',
          'rating': 3,
          'timestamp': nowUtc.subtract(const Duration(days: 1)).toIso8601String(),
          'languagePairKey': 'en-ar',
        },
        {
          'reviewEventId': '2',
          'learnerContentKey': 'key2',
          'rating': 3,
          'timestamp': nowUtc.subtract(const Duration(days: 1)).toIso8601String(),
          'languagePairKey': 'fr-ar',
        },
      ];

      final result = await LocalLearningAnalytics.generateReport(
        testHistory: history,
        testNowUtc: nowString,
        languagePairKey: 'en-ar',
      );

      final data = result as LocalAnalyticsData;
      expect(data.totalReviews, 1);
    });

    test('computes metrics accurately (daily, completion, recall, trend)', () async {
      final t1 = nowUtc.subtract(const Duration(days: 20)).toIso8601String(); // First half
      final t2 = nowUtc.subtract(const Duration(days: 5)).toIso8601String(); // Second half

      final history = [
        // First half (1 correct, 1 wrong = 50% ratio)
        {
          'reviewEventId': '1',
          'learnerContentKey': 'k1',
          'rating': 3,
          'timestamp': t1,
          'languagePairKey': 'en-ar',
        },
        {
          'reviewEventId': '2',
          'learnerContentKey': 'k2',
          'rating': 0,
          'timestamp': t1,
          'languagePairKey': 'en-ar',
        },
        // Second half (2 correct = 100% ratio) -> Trend should be upward
        {
          'reviewEventId': '3',
          'learnerContentKey': 'k1', // Duplicate key
          'rating': 3,
          'timestamp': t2,
          'languagePairKey': 'en-ar',
        },
        {
          'reviewEventId': '4',
          'learnerContentKey': 'k3',
          'rating': 2,
          'timestamp': t2,
          'languagePairKey': 'en-ar',
        },
      ];

      final result = await LocalLearningAnalytics.generateReport(
        testHistory: history,
        testNowUtc: nowString,
      );

      final data = result as LocalAnalyticsData;

      expect(data.totalReviews, 4);
      expect(data.recallAccuracy, 3 / 4); // 3 correct out of 4 total

      // Completion rate: unique keys = k1, k2, k3.
      // k1 passed (in both t1 and t2)
      // k2 did not pass (rating 0)
      // k3 passed (rating 2)
      // So passed = 2, unique = 3
      expect(data.completionRate, 2 / 3);

      // Trend: 100% in second half vs 50% in first half -> upward
      expect(data.learningTrend, 'upward');

      // Daily reviews: should have two distinct dates
      expect(data.dailyReviews.length, 2);
    });

    test('handles source records with missing optional values safely', () async {
       final history = [
        {
          'reviewEventId': '1', // Missing content key
          'timestamp': nowUtc.subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'learnerContentKey': 'k2', // Missing reviewEventId
          'timestamp': nowUtc.subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'reviewEventId': '3',
          'learnerContentKey': 'k3', // Missing timestamp
        },
        {
          'reviewEventId': '4',
          'learnerContentKey': 'k4',
          'rating': null, // Missing rating
          'timestamp': nowUtc.subtract(const Duration(days: 1)).toIso8601String(),
        }
      ];

      final result = await LocalLearningAnalytics.generateReport(
        testHistory: history,
        testNowUtc: nowString,
      );

      final data = result as LocalAnalyticsData;
      expect(data.totalReviews, 1); // Only the 4th record should pass basic field checks
      expect(data.recallAccuracy, 0.0); // rating null -> defaults to 0 -> isCorrect = false
    });
  });

  group('Timezone Boundaries', () {
    test('groups events into explicit local day even if UTC day differs', () async {
      final nowString = '2023-10-15T12:00:00Z';
      final baseTimeUtc = DateTime.parse(nowString).toUtc();

      final timestamp = baseTimeUtc.toIso8601String();

      final history = [
        {
          'reviewEventId': '1',
          'learnerContentKey': 'k1',
          'rating': 3,
          'timestamp': timestamp,
          'languagePairKey': 'en-ar',
        }
      ];

      final result = await LocalLearningAnalytics.generateReport(
        testHistory: history,
        testNowUtc: nowString,
      );

      final data = result as LocalAnalyticsData;
      // It should have exactly one date key
      expect(data.dailyReviews.length, 1);

      final localExpected = baseTimeUtc.toLocal();
      final expectedDateKey = "${localExpected.year.toString().padLeft(4, '0')}-${localExpected.month.toString().padLeft(2, '0')}-${localExpected.day.toString().padLeft(2, '0')}";
      expect(data.dailyReviews.keys.first, expectedDateKey);
    });
  });
}
