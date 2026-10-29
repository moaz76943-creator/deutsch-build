import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cognitive/cognitive_metric_record.dart';
import 'package:deutsch_bilarabi/core/cognitive/adaptive_cognitive_engine.dart';

void main() {
  group('Adaptive Cognitive Engine Tests', () {
    late AdaptiveCognitiveEngine engine;

    setUp(() {
      engine = AdaptiveCognitiveEngine.instance;
      engine.clearSession(); // Clear all state
    });

    test('safe cold-start behavior when no history exists', () {
      final decision = engine.evaluateDetailedState(targetLanguageCode: 'de');
      expect(decision.action, AdaptationAction.maintainFlow);
      expect(decision.reason, isA<InsufficientData>());
    });

    test('repeated mistakes lead to fatigue detection', () {
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'EVT_$i',
          contentKey: 'CARD_$i',
          responseLatency: const Duration(milliseconds: 6000),
          hesitationTaps: 2,
          isCorrect: false,
          recordedAt: DateTime.now(),
          targetLanguageCode: 'de',
        ));
      }

      final decision = engine.evaluateDetailedState(targetLanguageCode: 'de');
      expect(decision.action, AdaptationAction.reduceExtraneousLoad);
      expect(decision.reason, isA<FatigueDetected>());
    });

    test('improvement and mastery lead to deeper challenge', () {
      for (int i = 0; i < 4; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'EVT_FAST_$i',
          contentKey: 'CARD_FAST_$i',
          responseLatency: const Duration(milliseconds: 1200),
          hesitationTaps: 0,
          isCorrect: true,
          recordedAt: DateTime.now(),
          targetLanguageCode: 'de',
        ));
      }

      final decision = engine.evaluateDetailedState(targetLanguageCode: 'de');
      expect(decision.action, AdaptationAction.deepenLinguisticChallenge);
      expect(decision.reason, isA<ConsistentMastery>());
    });

    test('one language pair\'s performance does not affect another', () {
      // Add mastery records for 'de'
      for (int i = 0; i < 4; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'EVT_FAST_$i',
          contentKey: 'CARD_FAST_$i',
          responseLatency: const Duration(milliseconds: 1200),
          hesitationTaps: 0,
          isCorrect: true,
          recordedAt: DateTime.now(),
          targetLanguageCode: 'de',
        ));
      }

      // 'es' should still be in a cold-start state
      final esDecision = engine.evaluateDetailedState(targetLanguageCode: 'es');
      expect(esDecision.action, AdaptationAction.maintainFlow);
      expect(esDecision.reason, isA<InsufficientData>());
    });

    test('noisy/malformed metrics do not break computation', () {
      engine.observe(CognitiveMetricRecord(
        sessionEventId: 'EVT_NOISE',
        contentKey: 'CARD_NOISE',
        responseLatency: const Duration(milliseconds: -1000), // Negative latency
        hesitationTaps: -1, // Negative taps
        isCorrect: true,
        recordedAt: DateTime.now(),
        targetLanguageCode: 'de',
      ));

      final decision = engine.evaluateDetailedState(targetLanguageCode: 'de');
      // Should not crash, and a single item should result in stable flow or sufficient data
      expect(decision.action, AdaptationAction.maintainFlow);
      expect(decision.reason, isA<StableFlow>());
    });

    test('hysteresis prevents oscillating difficulty', () {
      final now = DateTime.now();

      // Trigger fatigue
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'EVT_FATIGUE_$i',
          contentKey: 'CARD_$i',
          responseLatency: const Duration(milliseconds: 6000),
          hesitationTaps: 2,
          isCorrect: false,
          recordedAt: now,
          targetLanguageCode: 'de',
        ));
      }

      // Initial decision should be reduce load
      final decision1 = engine.evaluateDetailedState(targetLanguageCode: 'de', currentTime: now);
      expect(decision1.action, AdaptationAction.reduceExtraneousLoad);

      // Now add 5 fast/correct answers immediately after (without time passing)
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'EVT_FAST_$i',
          contentKey: 'CARD_$i',
          responseLatency: const Duration(milliseconds: 1200),
          hesitationTaps: 0,
          isCorrect: true,
          recordedAt: now,
          targetLanguageCode: 'de',
        ));
      }

      // Should be blocked by hysteresis (return the previous state's action + HysteresisCoolDown)
      final decision2 = engine.evaluateDetailedState(targetLanguageCode: 'de', currentTime: now.add(const Duration(minutes: 1)));
      expect(decision2.action, AdaptationAction.reduceExtraneousLoad);
      expect(decision2.reason, isA<HysteresisCoolDown>());

      // After 6 minutes, it should allow change to deepen challenge
      final decision3 = engine.evaluateDetailedState(targetLanguageCode: 'de', currentTime: now.add(const Duration(minutes: 6)));
      expect(decision3.action, AdaptationAction.deepenLinguisticChallenge);
      expect(decision3.reason, isA<ConsistentMastery>());
    });
  });
}
