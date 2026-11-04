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
      // Send 5 incorrect, high latency records for 'en-de' (high strain)
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

      // Send 5 correct, fast records for 'ar-en' (low strain, but unverified)
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
      // Should block deepening if unverified
      expect(arDecision.action, AdaptationAction.maintainFlow);
    });

    test('Repeated mistakes triggers reduceExtraneousLoad', () {
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          isCorrect: false,
          recordedAt: DateTime.now(),
          targetLanguageCode: 'default_pair',
        ));
      }

      final decision = engine.evaluateDetailedState(targetLanguageCode: 'default_pair');
      expect(decision.action, AdaptationAction.reduceExtraneousLoad);
    });

    test('Hysteresis prevents oscillating difficulty (proper flow)', () {
       // Induce high strain
       final now = DateTime.now();
       for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          isCorrect: false,
          recordedAt: now,
          targetLanguageCode: 'default_pair',
        ));
      }
      expect(engine.evaluateDetailedState(targetLanguageCode: 'default_pair', currentTime: now).action, AdaptationAction.reduceExtraneousLoad);

      // Add 5 moderate strain records to replace the window
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'mod_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6), // 0.4 strain
          isCorrect: true,
          recordedAt: now,
          targetLanguageCode: 'default_pair',
        ));
      }

      // Should be blocked by hysteresis
      final decision = engine.evaluateDetailedState(targetLanguageCode: 'default_pair', currentTime: now);
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
        targetLanguageCode: 'default_pair',
      ));

      final decision = engine.evaluateDetailedState(targetLanguageCode: 'default_pair');
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
          isCefrVerified: false, // Unverified!
          targetLanguageCode: 'default_pair',
        ));
      }

      final decision = engine.evaluateDetailedState(targetLanguageCode: 'default_pair');
      expect(decision.action, AdaptationAction.maintainFlow);
    });

    test('CEFR verified allows deepening', () {
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'fast_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(milliseconds: 500),
          isCorrect: true,
          recordedAt: DateTime.now(),
          isCefrVerified: true, // Verified!
          targetLanguageCode: 'default_pair',
        ));
      }

      final decision = engine.evaluateDetailedState(targetLanguageCode: 'default_pair');
      expect(decision.action, AdaptationAction.deepenLinguisticChallenge);
    });
  });
}
