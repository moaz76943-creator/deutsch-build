import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/features/gamification/local_learning_analytics.dart';

void main() {
  const pair = DirectedPairId(
      sourceLocale: 'de', targetLocale: 'ar', semanticVersion: 'v2');
  const reverse = DirectedPairId(
      sourceLocale: 'ar', targetLocale: 'de', semanticVersion: 'v2');
  final reference = DateTime.utc(2026, 10, 13, 12);

  ReviewTransactionEnvelope event(String id, String key, int rating) =>
      ReviewTransactionEnvelope(
        reviewEventId: id,
        learnerContentKey: 'card',
        rating: rating,
        timestamp: DateTime.utc(2026, 10, 12),
        languagePairKey: key,
      );

  test('empty history is factual and does not manufacture mastery', () async {
    final outcome = await LocalLearningAnalytics.generateReport(
      history: [], pairId: pair, daysWindow: 30, referenceDateUtc: reference);
    expect(outcome.isSuccess, isTrue);
    expect(outcome.data.totalReviews, 0);
    expect(outcome.data.masteredCards, isNull);
    expect(outcome.data.completionRate, isNull);
  });

  test('duplicate events do not double advance analytics', () async {
    final e = event('one', pair.uniqueKey, 3);
    final outcome = await LocalLearningAnalytics.generateReport(
      history: [e, e], pairId: pair, daysWindow: 30,
      referenceDateUtc: reference);
    expect(outcome.isSuccess, isTrue);
    expect(outcome.data.totalReviews, 1);
    expect(outcome.data.recallAccuracy, 1.0);
  });

  test('directed reverse pairs and other versions are isolated', () async {
    final outcome = await LocalLearningAnalytics.generateReport(
      history: [
        event('one', pair.uniqueKey, 2),
        event('two', reverse.uniqueKey, 0),
        event('three', 'de_ar_v1', 1),
      ],
      pairId: pair,
      daysWindow: 30,
      referenceDateUtc: reference,
    );
    expect(outcome.isSuccess, isTrue);
    expect(outcome.data.totalReviews, 1);
  });

  test('same ID with conflicting payload fails closed', () async {
    final outcome = await LocalLearningAnalytics.generateReport(
      history: [
        event('one', pair.uniqueKey, 0),
        event('one', pair.uniqueKey, 3),
      ],
      pairId: pair,
      daysWindow: 30,
      referenceDateUtc: reference,
    );
    expect(outcome.isSuccess, isFalse);
  });

  test('invalid rating and excessively large window fail closed', () async {
    final bad = await LocalLearningAnalytics.generateReport(
      history: [event('bad', pair.uniqueKey, 99)],
      pairId: pair,
      daysWindow: 30,
      referenceDateUtc: reference,
    );
    expect(bad.isSuccess, isFalse);
    final invalid = await LocalLearningAnalytics.generateReport(
      history: [], pairId: pair, daysWindow: 10000,
      referenceDateUtc: reference,
    );
    expect(invalid.isSuccess, isFalse);
  });

  test('legacy no-evidence report and badges are not fabricated', () async {
    final old = await LocalLearningAnalytics.generate30DayReport();
    expect(old['mastered_cards'], isNull);
    expect(old['is_verified'], isFalse);
    expect(await LocalLearningAnalytics.checkNewBadge(), isNull);
  });
}
