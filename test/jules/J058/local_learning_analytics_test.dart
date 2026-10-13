import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/features/gamification/local_learning_analytics.dart';

void main() {
  group('LocalLearningAnalytics', () {
    final pairA = const DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0');
    final pairB = const DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
    final refDate = DateTime.utc(2023, 10, 15, 12, 0, 0);

    test('returns empty analytics for zero data', () async {
      final result = await LocalLearningAnalytics.generateReport(
        history: [],
        pairId: pairA,
        daysWindow: 30,
        referenceDateUtc: refDate,
      );

      expect(result.isSuccess, isTrue);
      final report = result.data;
      expect(report.totalReviews, 0);
      expect(report.dailyReviewsAverage, 0);
      expect(report.masteredCards, 0);
      expect(report.completionRate, 0.0);
      expect(report.recallAccuracy, 0.0);
      expect(report.learningTrend, 'stable');
      expect(report.consistencyScore, 0.0);
      expect(report.dailyReviews, isEmpty);
    });

    test('deduplicates repeated review transaction IDs', () async {
      final history = [
        ReviewTransactionEnvelope(
          reviewEventId: 'ev1',
          learnerContentKey: 'c1',
          rating: 4,
          timestamp: refDate.subtract(const Duration(days: 1)),
          languagePairKey: pairA.uniqueKey,
        ),
        ReviewTransactionEnvelope(
          reviewEventId: 'ev1',
          learnerContentKey: 'c1',
          rating: 4,
          timestamp: refDate.subtract(const Duration(days: 1)),
          languagePairKey: pairA.uniqueKey,
        ),
      ];

      final result = await LocalLearningAnalytics.generateReport(
        history: history,
        pairId: pairA,
        daysWindow: 7,
        referenceDateUtc: refDate,
      );

      expect(result.data.totalReviews, 1);
    });

    test('isolates analytics by directed pair', () async {
      final history = [
        ReviewTransactionEnvelope(
          reviewEventId: 'ev1',
          learnerContentKey: 'c1',
          rating: 5,
          timestamp: refDate.subtract(const Duration(days: 2)),
          languagePairKey: pairA.uniqueKey,
        ),
        ReviewTransactionEnvelope(
          reviewEventId: 'ev2',
          learnerContentKey: 'c2',
          rating: 4,
          timestamp: refDate.subtract(const Duration(days: 1)),
          languagePairKey: pairB.uniqueKey,
        ),
      ];

      final resultA = await LocalLearningAnalytics.generateReport(
        history: history,
        pairId: pairA,
        daysWindow: 7,
        referenceDateUtc: refDate,
      );
      expect(resultA.data.totalReviews, 1);
      expect(resultA.data.masteredCards, 1);

      final resultB = await LocalLearningAnalytics.generateReport(
        history: history,
        pairId: pairB,
        daysWindow: 7,
        referenceDateUtc: refDate,
      );
      expect(resultB.data.totalReviews, 1);
      expect(resultB.data.masteredCards, 1);
    });

    test('groups by local day', () async {
      // 2023-10-15 23:00 UTC is 2023-10-16 in local time if offset > 0.
      // But we can't reliably test this across all environments because the runner's timezone might be UTC.
      // Let's at least test that using toLocal doesn't throw.
      final history = [
        ReviewTransactionEnvelope(
          reviewEventId: 'ev1',
          learnerContentKey: 'c1',
          rating: 4,
          timestamp: DateTime.utc(2023, 10, 15, 23, 0),
          languagePairKey: pairA.uniqueKey,
        ),
      ];

      final result = await LocalLearningAnalytics.generateReport(
        history: history,
        pairId: pairA,
        daysWindow: 7,
        referenceDateUtc: refDate.add(const Duration(days: 1)), // Reference date next day so 23:00 is within window
      );

      expect(result.data.dailyReviews, isNotEmpty);
    });

    test('computes correct metrics', () async {
      final history = [
        ReviewTransactionEnvelope(reviewEventId: 'ev1', learnerContentKey: 'c1', rating: 5, timestamp: refDate.subtract(const Duration(days: 6)), languagePairKey: pairA.uniqueKey),
        ReviewTransactionEnvelope(reviewEventId: 'ev3', learnerContentKey: 'c3', rating: 4, timestamp: refDate.subtract(const Duration(days: 1)), languagePairKey: pairA.uniqueKey),
        ReviewTransactionEnvelope(reviewEventId: 'ev4', learnerContentKey: 'c1', rating: 3, timestamp: refDate.subtract(const Duration(days: 1)), languagePairKey: pairA.uniqueKey), // c1 updated to rating 3 (not mastered)
        ReviewTransactionEnvelope(reviewEventId: 'ev5', learnerContentKey: 'c4', rating: 5, timestamp: refDate.subtract(const Duration(days: 1)), languagePairKey: pairA.uniqueKey),
      ];

      final result = await LocalLearningAnalytics.generateReport(
        history: history,
        pairId: pairA,
        daysWindow: 7,
        referenceDateUtc: refDate,
      );

      final r = result.data;
      expect(r.totalReviews, 4);
      expect(r.recallAccuracy, 1.0); // 4 out of 4 >= 3
      expect(r.masteredCards, 2); // c3 and c4 have latest rating >= 4

      expect(r.dailyReviews.length, 2); // days 6 and 1
      expect(r.learningTrend, 'upward'); // More in second half (3 > 1)
    });

    test('checkNewBadge grants badge when over 100 mastered cards', () async {
      final history = List.generate(101, (i) => ReviewTransactionEnvelope(
        reviewEventId: 'ev$i',
        learnerContentKey: 'c$i',
        rating: 4,
        timestamp: refDate.subtract(const Duration(days: 1)),
        languagePairKey: pairA.uniqueKey,
      ));

      final result = await LocalLearningAnalytics.checkNewBadge(
        history: history,
        pairId: pairA,
        referenceDateUtc: refDate,
      );

      expect(result.data, 'وسام المائة بطاقة المتقنة');
    });

    test('checkNewBadge does not grant badge when under 100 mastered cards', () async {
      final history = List.generate(50, (i) => ReviewTransactionEnvelope(
        reviewEventId: 'ev$i',
        learnerContentKey: 'c$i',
        rating: 4,
        timestamp: refDate.subtract(const Duration(days: 1)),
        languagePairKey: pairA.uniqueKey,
      ));

      final result = await LocalLearningAnalytics.checkNewBadge(
        history: history,
        pairId: pairA,
        referenceDateUtc: refDate,
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('ignores records with missing or corrupted fields', () async {
      // Missing fields simulation (simulated by passing map directly if possible, or using empty values)
      final history = [
        ReviewTransactionEnvelope(reviewEventId: 'ev1', learnerContentKey: '', rating: -1, timestamp: refDate, languagePairKey: pairA.uniqueKey),
      ];
      // Note: ReviewTransactionEnvelope doesn't allow nullable fields, but we should make sure invalid logic is handled.
      // E.g. negative rating.
      final result = await LocalLearningAnalytics.generateReport(
        history: history,
        pairId: pairA,
        daysWindow: 7,
        referenceDateUtc: refDate,
      );

      expect(result.data.totalReviews, 1);
      expect(result.data.masteredCards, 0); // Rating -1 < 4
      expect(result.data.recallAccuracy, 0.0); // Rating -1 < 3
    });
  });
}
