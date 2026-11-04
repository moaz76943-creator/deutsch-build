import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cognitive/adaptive_cognitive_engine.dart';
import 'package:deutsch_bilarabi/core/cognitive/cognitive_metric_record.dart';

void main() {
  setUp(() {
    AdaptiveCognitiveEngine.instance.clearSession();
  });

  test('Fallback when empty', () {
    final decision = AdaptiveCognitiveEngine.instance.evaluateDetailedState();
    expect(decision.action, AdaptationAction.maintainFlow);
    expect(decision.reason, isA<InsufficientData>());
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
      expect(arDecision.action, AdaptationAction.maintainFlow); // Blocked due to unverified CEFR
    });

    test('Repeated mistakes triggers reduceExtraneousLoad', () {
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6), // Increase latency to guarantee high strain (latency > 5000 -> 0.4 + incorrect -> 0.3 = 0.7)
          isCorrect: false, // incorrect
          recordedAt: DateTime.now(),
          targetLanguageCode: 'default_pair',
        ));
      }

      final decision = engine.evaluateDetailedState();
      expect(decision.action, AdaptationAction.reduceExtraneousLoad);
    });

    test('Hysteresis prevents oscillating difficulty', () {
      // 1. Induce high strain -> reduceExtraneousLoad
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          isCorrect: false,
          recordedAt: DateTime.now(),
        ));
      }

      expect(engine.evaluateDetailedState().action, AdaptationAction.reduceExtraneousLoad);

      // 2. Introduce a few moderate strain records. Average strain will be > 0.3 but < 0.6
      // Let's clear and re-populate the window to easily control avgStrain
      engine.clearSession();
      for (int i = 0; i < 5; i++) {
         // This gives strain around 0.4 (slow, but correct, no taps)
         engine.observe(CognitiveMetricRecord(
          sessionEventId: 'mod_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6), // 0.4 strain
          isCorrect: true,
          recordedAt: DateTime.now(),
        ));
      }

      // Because we cleared, we need to artificially induce the last action or not clear.
      // Let's rewrite this part safely without clearing.
    });

    test('Hysteresis prevents oscillating difficulty (proper flow)', () {
       // Induce high strain
       for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'ev_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6),
          isCorrect: false,
          recordedAt: DateTime.now(),
        ));
      }
      expect(engine.evaluateDetailedState().action, AdaptationAction.reduceExtraneousLoad);

      // Add 5 moderate strain records to replace the window
      // strain: 0.4 per record (latency > 5000ms -> +0.4, correct -> +0.0, taps 0 -> +0.0)
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'mod_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6), // 0.4 strain
          isCorrect: true,
          recordedAt: DateTime.now(),
        ));
      }

      // avgStrain is 0.4. Normal threshold is 0.6. But because we were in reduceExtraneousLoad,
      // and 0.4 > 0.3, we should stay in reduceExtraneousLoad (hysteresis).
      final decision = engine.evaluateDetailedState();
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
      ));
    }
    final decision = AdaptiveCognitiveEngine.instance.evaluateDetailedState();
    expect(decision.action, AdaptationAction.maintainFlow);
    expect(decision.reason, isA<StableFlow>());
  });

      // With negatives clamped to 0, latency is 0 (< 2000), correct is true.
      // Since window size is 1 (< 3), it will maintainFlow, but importantly won't crash or give NaN strain
      final decision = engine.evaluateDetailedState();
      expect(decision.action, AdaptationAction.maintainFlow);
    });

  test('Missing/Negative values handled gracefully', () {
    AdaptiveCognitiveEngine.instance.observe(CognitiveMetricRecord(
      sessionEventId: 'evt_1',
      contentKey: 'word',
      responseLatency: const Duration(milliseconds: -1000),
      hesitationTaps: -2,
      isCorrect: true,
      recordedAt: DateTime.now(),
    ));
    final decision = AdaptiveCognitiveEngine.instance.evaluateDetailedState();
    expect(decision.action, AdaptationAction.maintainFlow);
  });

      final decision = engine.evaluateDetailedState();
      expect(decision.action, AdaptationAction.maintainFlow);
      expect(decision.reason, isA<UnverifiedCefrBlocked>());
    });

    // German pair - mastery
    for (int i = 0; i < 5; i++) {
      AdaptiveCognitiveEngine.instance.observe(CognitiveMetricRecord(
        sessionEventId: 'evt_$i',
        contentKey: 'word',
        responseLatency: const Duration(milliseconds: 1000),
        hesitationTaps: 0,
        isCorrect: true,
        recordedAt: DateTime.now(),
        targetLanguageCode: 'de',
        isCefrVerified: true,
      ));
    }

      final decision = engine.evaluateDetailedState();
      expect(decision.action, AdaptationAction.deepenLinguisticChallenge);
    });
  });
}
