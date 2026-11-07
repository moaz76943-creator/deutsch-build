import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/gamification/local_learning_analytics.dart';
import 'package:deutsch_bilarabi/core/progress/sqlite_review_transaction_port.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/progress/transaction_persistence_port.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'package:sqflite/sqflite.dart';

class StubSqliteReviewTransactionPort implements SqliteReviewTransactionPort {
  Map<String, List<ReviewTransactionEnvelope>> _data = {};

  void stubReadCommittedReviews(String pairKey, List<ReviewTransactionEnvelope> envelopes) {
    _data[pairKey] = envelopes;
  }

  @override
  Future<List<ReviewTransactionEnvelope>> readCommittedReviews({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String semanticVersion,
    int limit = 50000,
  }) async {
    final key = '${sourceLanguageId}_${targetLanguageId}_$semanticVersion';
    return _data[key] ?? [];
  }

  @override
  AtomicReviewMutation get applyReview => throw UnimplementedError();

  @override
  Future<ReviewCommitResult> commitOnce({required ReviewCommand command, required ReviewTransactionEnvelope envelope}) {
    throw UnimplementedError();
  }

  @override
  Database get database => throw UnimplementedError();
}

void main() {
  late StubSqliteReviewTransactionPort mockPort;
  final nowUtc = DateTime.utc(2023, 10, 10, 12, 0, 0);

  final pair1 = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');
  final pair2 = DirectedPairId(sourceLocale: 'ar', targetLocale: 'en', semanticVersion: '1.0.0');

  setUp(() {
    mockPort = StubSqliteReviewTransactionPort();
  });

  test('generates AnalyticsUnavailableState for empty records', () async {
    final result = await LocalLearningAnalytics.generateReport(
      port: mockPort,
      activePairs: [pair1],
      window: AnalyticsWindow.days30,
      nowUtc: nowUtc,
    );
    expect(result, isA<AnalyticsUnavailableState>());
  });

  test('calculates correct metrics for a single pair and handles repeated events', () async {
    final env1 = ReviewTransactionEnvelope(
      reviewEventId: 'ev1',
      learnerContentKey: 'card1',
      rating: 4,
      timestamp: nowUtc.subtract(const Duration(days: 1)),
      languagePairKey: pair1.uniqueKey,
    );
    final env2 = ReviewTransactionEnvelope(
      reviewEventId: 'ev1',
      learnerContentKey: 'card1',
      rating: 1,
      timestamp: nowUtc.subtract(const Duration(days: 1)),
      languagePairKey: pair1.uniqueKey,
    );
    final env3 = ReviewTransactionEnvelope(
      reviewEventId: 'ev2',
      learnerContentKey: 'card2',
      rating: 2,
      timestamp: nowUtc.subtract(const Duration(days: 2)),
      languagePairKey: pair1.uniqueKey,
    );

    mockPort.stubReadCommittedReviews(pair1.uniqueKey, [env1, env2, env3]);

    final result = await LocalLearningAnalytics.generateReport(
      port: mockPort,
      activePairs: [pair1],
      window: AnalyticsWindow.days30,
      nowUtc: nowUtc,
    );

    expect(result, isA<AnalyticsDataState>());
    final state = result as AnalyticsDataState;
    final metrics = state.pairSpecificMetrics[pair1.uniqueKey]!;

    expect(metrics.totalReviews, 2);
    expect(metrics.recallAccuracy, 0.5);
    expect(metrics.uniqueCardsMastered, 1);
    expect(metrics.completionRate, 0.5);

    final day1 = nowUtc.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
    final day2 = nowUtc.subtract(const Duration(days: 2)).toIso8601String().substring(0, 10);
    expect(metrics.dailyReviews[day1], 1);
    expect(metrics.dailyReviews[day2], 1);
  });

  test('filters out records outside the analytics window', () async {
    final env1 = ReviewTransactionEnvelope(
      reviewEventId: 'ev1',
      learnerContentKey: 'card1',
      rating: 4,
      timestamp: nowUtc.subtract(const Duration(days: 8)),
      languagePairKey: pair1.uniqueKey,
    );

    mockPort.stubReadCommittedReviews(pair1.uniqueKey, [env1]);

    final result = await LocalLearningAnalytics.generateReport(
      port: mockPort,
      activePairs: [pair1],
      window: AnalyticsWindow.days7,
      nowUtc: nowUtc,
    );

    expect(result, isA<AnalyticsUnavailableState>());
  });

  test('handles pair switching appropriately (isolation)', () async {
    final env1 = ReviewTransactionEnvelope(
      reviewEventId: 'ev1',
      learnerContentKey: 'card1',
      rating: 4,
      timestamp: nowUtc.subtract(const Duration(days: 1)),
      languagePairKey: pair1.uniqueKey,
    );
    final env2 = ReviewTransactionEnvelope(
      reviewEventId: 'ev2',
      learnerContentKey: 'card2',
      rating: 4,
      timestamp: nowUtc.subtract(const Duration(days: 1)),
      languagePairKey: pair2.uniqueKey,
    );

    mockPort.stubReadCommittedReviews(pair1.uniqueKey, [env1]);
    mockPort.stubReadCommittedReviews(pair2.uniqueKey, [env2]);

    final result = await LocalLearningAnalytics.generateReport(
      port: mockPort,
      activePairs: [pair1, pair2],
      window: AnalyticsWindow.days30,
      nowUtc: nowUtc,
    );

    expect(result, isA<AnalyticsDataState>());
    final state = result as AnalyticsDataState;
    expect(state.pairSpecificMetrics.keys, containsAll([pair1.uniqueKey, pair2.uniqueKey]));
  });

  test('timezone boundaries and local-day grouping (UTC part)', () async {
    final dt1 = DateTime.utc(2023, 10, 10, 23, 59, 59);
    final dt2 = DateTime.utc(2023, 10, 11, 0, 0, 1);

    final env1 = ReviewTransactionEnvelope(
      reviewEventId: 'ev1', learnerContentKey: 'c1', rating: 4, timestamp: dt1, languagePairKey: pair1.uniqueKey,
    );
    final env2 = ReviewTransactionEnvelope(
      reviewEventId: 'ev2', learnerContentKey: 'c2', rating: 4, timestamp: dt2, languagePairKey: pair1.uniqueKey,
    );

    mockPort.stubReadCommittedReviews(pair1.uniqueKey, [env1, env2]);

    final result = await LocalLearningAnalytics.generateReport(
      port: mockPort,
      activePairs: [pair1],
      window: AnalyticsWindow.days30,
      nowUtc: DateTime.utc(2023, 10, 12, 12, 0, 0),
    );

    expect(result, isA<AnalyticsDataState>());
    final state = result as AnalyticsDataState;
    final metrics = state.pairSpecificMetrics[pair1.uniqueKey]!;

    expect(metrics.dailyReviews.keys, containsAll(['2023-10-10', '2023-10-11']));
  });

  test('handles source records with missing optional values and corrupt maps', () {
    final nowUtcIso = DateTime.utc(2023, 10, 10).toIso8601String();
    final malformedMap = {
      'history': [
         {
           'learnerContentKey': 'c1',
           'rating': 4,
           'timestamp': nowUtcIso,
           'languagePairKey': pair1.uniqueKey,
         },
         {
           'reviewEventId': 'ev2',
           'rating': 4,
           'timestamp': nowUtcIso,
           'languagePairKey': pair1.uniqueKey,
         },
         {
           'reviewEventId': 'ev3',
           'learnerContentKey': 'c3',
           'timestamp': nowUtcIso,
           'languagePairKey': pair1.uniqueKey,
         },
         {
           'reviewEventId': 'ev4',
           'learnerContentKey': 'c4',
           'rating': 4,
           'languagePairKey': pair1.uniqueKey,
         },
         {
           'reviewEventId': 'ev5',
           'learnerContentKey': 'c5',
           'rating': 4,
           'timestamp': 'invalid-date',
           'languagePairKey': pair1.uniqueKey,
         },
         {
           'reviewEventId': 'ev6',
           'learnerContentKey': 'c6',
           'rating': 4,
           'timestamp': nowUtcIso,
           'languagePairKey': pair1.uniqueKey,
         }
      ],
      'windowDays': 30,
      'currentUtc': nowUtcIso,
    };

    final result = LocalLearningAnalytics.aggregateHistoryForTesting(malformedMap);

    expect(result.keys, contains(pair1.uniqueKey));
    expect(result[pair1.uniqueKey]!.totalReviews, 1);
    expect(result[pair1.uniqueKey]!.uniqueCardsMastered, 1);
  });
}
