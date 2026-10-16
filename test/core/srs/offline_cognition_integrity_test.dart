import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cognitive/adaptive_cognitive_engine.dart';
import 'package:deutsch_bilarabi/core/cognitive/cognitive_metric_record.dart';
import 'package:deutsch_bilarabi/core/gamification/streak_freeze_ledger.dart';
import 'package:deutsch_bilarabi/features/gamification/local_learning_analytics.dart';

CognitiveMetricRecord metric(String id, String pair,
    {bool correct = true, int latencyMs = 500}) => CognitiveMetricRecord(
  sessionEventId: id, contentKey: 'card', languagePair: pair,
  responseLatency: Duration(milliseconds: latencyMs),
  isCorrect: correct, recordedAt: DateTime.utc(2026, 10, 13),
);

void main() {
  group('pair-bounded cognitive estimates', () {
    final engine = AdaptiveCognitiveEngine.instance;
    setUp(engine.clearSession);

    test('directed pairs must not influence each other', () {
      for (var i = 0; i < 3; i++) {
        engine.observe(metric('x$i', 'de_ar', correct: false, latencyMs: 7000));
        engine.observe(metric('y$i', 'ar_de'));
      }
      expect(engine.evaluateStateDetailed(languagePair: 'de_ar').action,
          AdaptationAction.reduceExtraneousLoad);
      expect(engine.evaluateStateDetailed(languagePair: 'ar_de').action,
          AdaptationAction.deepenLinguisticChallenge);
    });

    test('replay does not supply fabricated sample size', () {
      final event = metric('same-id', 'de_ar', correct: false, latencyMs: 7000);
      for (var i = 0; i < 5; i++) { engine.observe(event); }
      expect(engine.evaluateStateDetailed(languagePair: 'de_ar').action,
          AdaptationAction.maintainFlow);
    });

    test('recover gradually without high-frequency oscillation', () {
      for (var i = 0; i < 5; i++) {
        engine.observe(metric('hard$i', 'de_ar', correct: false, latencyMs: 7000));
      }
      expect(engine.evaluateStateDetailed(languagePair: 'de_ar').action,
          AdaptationAction.reduceExtraneousLoad);
      for (var i = 0; i < 5; i++) {
        engine.observe(metric('medium$i', 'de_ar', latencyMs: 6000));
      }
      expect(engine.evaluateStateDetailed(languagePair: 'de_ar').action,
          AdaptationAction.reduceExtraneousLoad);
      for (var i = 0; i < 5; i++) {
        engine.observe(metric('easy$i', 'de_ar'));
      }
      expect(engine.evaluateStateDetailed(languagePair: 'de_ar').action,
          AdaptationAction.deepenLinguisticChallenge);
    });

    test('malformed latency or identities cannot boost cognition', () {
      engine.observe(metric('noise', 'de_ar', latencyMs: -500));
      engine.observe(metric('', 'de_ar'));
      expect(engine.evaluateStateDetailed(languagePair: 'de_ar').action,
          AdaptationAction.maintainFlow);
    });
  });

  group('streak protection', () {
    test('replayed freeze on one local day consumes at most one shield', () {
      final now = DateTime.utc(2026, 10, 13, 10);
      var ledger = const StreakFreezeLedger();
      ledger = ledger.recordUsage('missed', timestamp: now);
      ledger = ledger.recordUsage('again', timestamp: now);
      expect(ledger.remainingShields, 1);
      expect(ledger.usageHistory.length, 1);
    });
    test('exhausted and negative shield balances never go below zero', () {
      const malformed = StreakFreezeLedger(totalShields: -5);
      expect(malformed.remainingShields, 0);
      expect(malformed.canConsume, false);
      expect(malformed.recordUsage('attempt').remainingShields, 0);
    });
  });

  test('analytics without committed evidence never invents achievements', () async {
    final summary = await LocalLearningAnalytics.generate30DayReport();
    expect(summary['mastered_cards'], 0);
    expect(summary['active_domains'], 0);
    expect(summary['consistency_score'], 0);
    expect(await LocalLearningAnalytics.checkNewBadge(), isNull);
  });
}
