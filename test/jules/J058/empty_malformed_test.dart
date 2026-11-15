import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/gamification/local_learning_analytics.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'test_helpers.dart';

void main() {
  group('LocalLearningAnalytics Empty and Malformed - J058', () {
    test('handles zero data correctly by simulating empty history check on unique isolated pair', () async {
      final mockPort = StubSqliteReviewTransactionPort();
      final result = await LocalLearningAnalytics.generateReport(
        port: mockPort,
        activePairs: [],
        window: AnalyticsWindow.days30
      );

      expect(result, isA<AnalyticsUnavailableState>());
    });

    test('handles missing optional values gracefully via raw map injection (simulating db corruption)', () async {
      final nowUtc = DateTime.utc(2023, 10, 15, 12, 0);
      final String pair1 = 'ar_en_1.0.0';

      final malformedMap = {
        'history': [
           {
             'learnerContentKey': 'card-a',
             'rating': 3,
             'timestamp': DateTime.utc(2023, 10, 15, 1, 0).toIso8601String(),
             'languagePairKey': pair1,
           },
           {
             'reviewEventId': 'evt-1-$pair1',
             'learnerContentKey': 'card-b',
             'rating': 3,
             'timestamp': DateTime.utc(2023, 10, 15, 1, 0).toIso8601String(),
             'languagePairKey': pair1,
           }
        ],
        'windowDays': 30,
        'currentUtc': nowUtc.toIso8601String(),
      };

      final result = LocalLearningAnalytics.aggregateHistoryForTesting(malformedMap);
      expect(result[pair1]?.totalReviews, 1); // only evt-1 (second item) was valid
    });
  });
}
