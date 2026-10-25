import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cognitive/adaptive_cognitive_engine.dart';
import 'package:deutsch_bilarabi/core/cognitive/cognitive_metric_record.dart';

void main() {
  group('AdaptiveCognitiveEngine', () {
    late AdaptiveCognitiveEngine engine;

    setUp(() {
      engine = AdaptiveCognitiveEngine.instance;
      engine.clearSession();
    });

    test('Safe cold-start behavior', () {
      final decision = engine.evaluateStateDetailed(languagePair: 'en-de');
      expect(decision.action, AdaptationAction.maintainFlow);
      expect(decision.reason, isA<InsufficientData>());
    });

    test('Isolated language pairs', () {
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_ende_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          hesitationTaps: 2,
          isCorrect: false,
          recordedAt: DateTime.now(),
          languagePair: 'en-de',
        ));
      }

      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_aren_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 1),
          isCorrect: true,
          recordedAt: DateTime.now(),
          languagePair: 'ar-en',
          isCefrVerified: false,
        ));
      }

      final deDecision = engine.evaluateStateDetailed(languagePair: 'en-de');
      expect(deDecision.action, AdaptationAction.reduceExtraneousLoad);

      final arDecision = engine.evaluateStateDetailed(languagePair: 'ar-en');
      expect(arDecision.action, AdaptationAction.maintainFlow);
      expect(arDecision.reason, isA<UnverifiedCefrBlocked>());
    });

    test('Repeated mistakes triggers reduceExtraneousLoad', () {
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          isCorrect: false,
          recordedAt: DateTime.now(),
        ));
      }

      final decision = engine.evaluateStateDetailed();
      expect(decision.action, AdaptationAction.reduceExtraneousLoad);
    });

    test('Hysteresis prevents oscillating difficulty', () {
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          isCorrect: false,
          recordedAt: DateTime.now(),
        ));
      }

      expect(engine.evaluateStateDetailed().action, AdaptationAction.reduceExtraneousLoad);
    });

    test('Hysteresis prevents oscillating difficulty (proper flow)', () {
       final now = DateTime.now();
       for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          isCorrect: false,
          recordedAt: now,
        ));
      }
      expect(engine.evaluateStateDetailed(currentTime: now).action, AdaptationAction.reduceExtraneousLoad);

      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'mod_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          isCorrect: true,
          recordedAt: now,
        ));
      }

      final decision = engine.evaluateStateDetailed(currentTime: now);
      expect(decision.action, AdaptationAction.reduceExtraneousLoad);
      expect(decision.reason, isA<HysteresisCoolDown>());
    });

    test('Noisy metrics (negative latency/taps)', () {
      engine.observe(CognitiveMetricRecord(
        sessionEventId: 'noise',
        contentKey: 'ck',
        responseLatency: const Duration(seconds: -10),
        hesitationTaps: -5,
        isCorrect: true,
        recordedAt: DateTime.now(),
        reviewDifficulty: double.nan,
      ));

      final decision = engine.evaluateStateDetailed();
      expect(decision.action, AdaptationAction.maintainFlow);
    });

    test('CEFR unverified prevention', () {
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'fast_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(milliseconds: 500),
          isCorrect: true,
          recordedAt: DateTime.now(),
          isCefrVerified: false,
        ));
      }

      final decision = engine.evaluateStateDetailed();
      expect(decision.action, AdaptationAction.maintainFlow);
      expect(decision.reason, isA<UnverifiedCefrBlocked>());
    });

    test('CEFR verified allows deepening', () {
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'fast_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(milliseconds: 500),
          isCorrect: true,
          recordedAt: DateTime.now(),
          isCefrVerified: true,
        ));
      }

      final decision = engine.evaluateStateDetailed();
      expect(decision.action, AdaptationAction.deepenLinguisticChallenge);
    });
  });
}
