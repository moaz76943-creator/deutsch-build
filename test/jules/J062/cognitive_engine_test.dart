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
      expect(decision.reason, contains('cold-start'));
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
          languagePair: 'en-de',
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
          languagePair: 'ar-en',
          isCefrVerified: false,
        ));
      }

      final deDecision = engine.evaluateStateDetailed(languagePair: 'en-de');
      expect(deDecision.action, AdaptationAction.reduceExtraneousLoad);

      final arDecision = engine.evaluateStateDetailed(languagePair: 'ar-en');
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
          languagePair: 'default',
        ));
      }

      final decision = engine.evaluateStateDetailed(languagePair: 'default');
      expect(decision.action, AdaptationAction.reduceExtraneousLoad);
    });

    test('Hysteresis prevents oscillating difficulty (cleared check)', () {
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

      expect(engine.evaluateStateDetailed().action, AdaptationAction.reduceExtraneousLoad);

      // Clear session bypasses hysteresis
      engine.clearSession();
      for (int i = 0; i < 5; i++) {
         engine.observe(CognitiveMetricRecord(
          sessionEventId: 'mod_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 6), // 0.4 strain
          isCorrect: true,
          recordedAt: DateTime.now(),
        ));
      }

      expect(engine.evaluateStateDetailed().action, AdaptationAction.maintainFlow);
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
      expect(engine.evaluateStateDetailed().action, AdaptationAction.reduceExtraneousLoad);

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
      final decision = engine.evaluateStateDetailed();
      expect(decision.action, AdaptationAction.reduceExtraneousLoad);
      expect(decision.reason, contains('Hysteresis'));
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

      // With negatives clamped to 0, latency is 0 (< 2000), correct is true.
      // Since window size is 1 (< 3), it will maintainFlow, but importantly won't crash or give NaN strain
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
          isCefrVerified: false, // Unverified!
        ));
      }

      final decision = engine.evaluateStateDetailed();
      expect(decision.action, AdaptationAction.maintainFlow);
      expect(decision.reason, contains('blocked: unverified'));
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
        ));
      }

      final decision = engine.evaluateStateDetailed();
      expect(decision.action, AdaptationAction.deepenLinguisticChallenge);
    });

    test('Easy item incorrect increases strain', () {
      final record = CognitiveMetricRecord(
        sessionEventId: 'ev',
        contentKey: 'ck',
        responseLatency: const Duration(seconds: 1),
        isCorrect: false,
        recordedAt: DateTime.now(),
        reviewDifficulty: 0.1, // Easy
      );
      expect(record.cognitiveStrainIndex, closeTo(0.4, 0.01));
    });

    test('Hard item correct reduces strain', () {
      final record = CognitiveMetricRecord(
        sessionEventId: 'ev',
        contentKey: 'ck',
        responseLatency: const Duration(seconds: 6),
        isCorrect: true,
        recordedAt: DateTime.now(),
        reviewDifficulty: 0.9, // Hard
      );
      expect(record.cognitiveStrainIndex, closeTo(0.3, 0.01));
    });
  });
}
