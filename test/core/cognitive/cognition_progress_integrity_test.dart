import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cognitive/adaptive_cognitive_engine.dart';
import 'package:deutsch_bilarabi/core/cognitive/cognitive_metric_record.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';
import 'package:deutsch_bilarabi/core/gamification/domain_mastery_projection.dart';

CognitiveMetricRecord metric(String event, String pair, {
  bool correct = true, int latency = 1200,
}) => CognitiveMetricRecord(
  sessionEventId: event,
  contentKey: 'card-$event',
  languagePair: pair,
  responseLatency: Duration(milliseconds: latency),
  isCorrect: correct,
  recordedAt: DateTime.utc(2026, 10, 13),
);

void main() {
  group('bounded, pair-specific cognition', () {
    final engine = AdaptiveCognitiveEngine.instance;
    setUp(engine.clearSession);

    test('legacy fast correct responses still deepen without CEFR claims', () {
      for (var i = 0; i < 4; i++) {
        engine.observe(metric('e$i', 'default'));
      }
      expect(engine.evaluateState(), AdaptationAction.deepenLinguisticChallenge);
    });

    test('same event ignored; other directed pair is isolated', () {
      engine.observe(metric('e1', 'de_ar', correct: false, latency: 8000));
      engine.observe(metric('e1', 'de_ar', correct: false, latency: 8000));
      for (var i = 0; i < 3; i++) {
        engine.observe(metric('fast$i', 'ar_de'));
      }
      expect(engine.evaluateStateDetailed(languagePair: 'ar_de').action,
          AdaptationAction.deepenLinguisticChallenge);
      expect(engine.evaluateStateDetailed(languagePair: 'de_ar').action,
          AdaptationAction.reduceExtraneousLoad);
    });

    test('malformed latency does not become evidence of fast mastery', () {
      for (var i = 0; i < 3; i++) {
        engine.observe(metric('invalid$i', 'de_ar', latency: -1));
      }
      expect(engine.evaluateStateDetailed(languagePair: 'de_ar').action,
          AdaptationAction.maintainFlow);
    });

    test('resident pair count is bounded and oldest pair expires', () {
      for (var i = 0; i < 5; i++) {
        engine.observe(metric('bad$i', 'pair$i', correct: false, latency: 9000));
      }
      expect(engine.evaluateStateDetailed(languagePair: 'pair0').action,
          AdaptationAction.maintainFlow);
      expect(engine.evaluateStateDetailed(languagePair: 'pair4').action,
          AdaptationAction.reduceExtraneousLoad);
    });
  });

  group('streak freeze integrity', () {
    test('same local day consumes at most one shield', () {
      final a = StreakFreezeLedger()
          .recordUsage('miss', timestamp: DateTime(2026, 10, 13, 12));
      final b = a.recordUsage('retry', timestamp: DateTime(2026, 10, 13, 14));
      expect(b.remainingShields, 1);
      expect(b.usageHistory.length, 1);
    });

    test('negative balance and repeated legacy rows cannot underflow', () {
      final day = DateTime(2026, 10, 13);
      final ledger = StreakFreezeLedger(
        totalShields: -2,
        usageHistory: [
          FreezeUsageRecord(usedAt: day, reason: 'old'),
          FreezeUsageRecord(usedAt: day, reason: 'duplicate'),
        ],
      );
      expect(ledger.remainingShields, 0);
      expect(ledger.canConsume, false);
    });
  });

  test('verified mastery counters reject impossible states and pair reversal', () {
    DomainMasteryProjection build(String source, String target, int mastery) =>
        DomainMasteryProjection.fromVerifiedCounters(
          domainId: 'food',
          sourceLanguageId: source,
          targetLanguageId: target,
          eligibleCardCount: 3,
          introducedCardCount: 2,
          recalledCardCount: 1,
          masteredCardCount: mastery,
          dueCardCount: 1,
          lastEvidenceUtc: DateTime.utc(2026, 10, 13),
          masteryRevision: 2,
        );
    expect(build('de', 'ar', 1).masteryPercentage, closeTo(1 / 3, 0.001));
    expect(build('ar', 'de', 0).masteryPercentage, 0.0);
    expect(() => build('de', 'ar', 2), throwsArgumentError);
    expect(() => build('de', 'de', 0), throwsArgumentError);
  });
}
