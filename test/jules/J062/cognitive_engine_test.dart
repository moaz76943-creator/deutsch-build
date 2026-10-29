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
      final decision = engine.evaluateDetailedState(targetLanguageCode: 'en-de');
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
          targetLanguageCode: 'en-de',
        ));
      }

      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_aren_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 1),
          isCorrect: true,
          recordedAt: DateTime.now(),
          targetLanguageCode: 'ar-en',
          isCefrVerified: false,
        ));
      }

      final deDecision = engine.evaluateDetailedState(targetLanguageCode: 'en-de');
      expect(deDecision.action, AdaptationAction.reduceExtraneousLoad);

      final arDecision = engine.evaluateDetailedState(targetLanguageCode: 'ar-en');
      expect(arDecision.action, AdaptationAction.maintainFlow);
    });

    test('Repeated mistakes triggers reduceExtraneousLoad', () {
      // Add latency >= 5 seconds and incorrect -> strain 0.4 + 0.3 = 0.7 > 0.6
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          isCorrect: false,
          recordedAt: DateTime.now(),
          targetLanguageCode: 'default',
        ));
      }

      final decision = engine.evaluateDetailedState(targetLanguageCode: 'default');
      expect(decision.action, AdaptationAction.reduceExtraneousLoad);
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
      expect(engine.evaluateDetailedState(currentTime: now).action, AdaptationAction.reduceExtraneousLoad);

      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'mod_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          isCorrect: true,
          recordedAt: now,
        ));
      }

      final decision = engine.evaluateDetailedState(currentTime: now);
      expect(decision.action, AdaptationAction.reduceExtraneousLoad);
      expect(decision.reason, isA<HysteresisCoolDown>());
    });

    test('Noisy metrics (negative latency/taps/reviewDifficulty)', () {
      engine.observe(CognitiveMetricRecord(
        sessionEventId: 'noise',
        contentKey: 'ck',
        responseLatency: const Duration(seconds: -10),
        hesitationTaps: -5,
        isCorrect: true,
        recordedAt: DateTime.now(),
        reviewDifficulty: double.nan,
      ));

      final decision = engine.evaluateDetailedState();
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

      final decision = engine.evaluateDetailedState();
      expect(decision.action, AdaptationAction.maintainFlow);
      expect(decision.reason, isA<BlockedUnverified>());
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

      final decision = engine.evaluateDetailedState();
      expect(decision.action, AdaptationAction.deepenLinguisticChallenge);
    });
  });
}
