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

  test('Fatigue detected with high strain', () {
    for (int i = 0; i < 5; i++) {
      AdaptiveCognitiveEngine.instance.observe(CognitiveMetricRecord(
        sessionEventId: 'evt_$i',
        contentKey: 'word',
        responseLatency: const Duration(seconds: 6),
        hesitationTaps: 2,
        isCorrect: false,
        recordedAt: DateTime.now(),
      ));
    }
    final decision = AdaptiveCognitiveEngine.instance.evaluateDetailedState();
    expect(decision.action, AdaptationAction.reduceExtraneousLoad);
    expect(decision.reason, isA<FatigueDetected>());
  });

  test('Stable flow', () {
    for (int i = 0; i < 5; i++) {
      AdaptiveCognitiveEngine.instance.observe(CognitiveMetricRecord(
        sessionEventId: 'evt_$i',
        contentKey: 'word',
        responseLatency: const Duration(milliseconds: 2500),
        hesitationTaps: 0,
        isCorrect: true,
        recordedAt: DateTime.now(),
      ));
    }
    final decision = AdaptiveCognitiveEngine.instance.evaluateDetailedState();
    expect(decision.action, AdaptationAction.maintainFlow);
    expect(decision.reason, isA<StableFlow>());
  });

  test('Deepen challenge', () {
    for (int i = 0; i < 5; i++) {
      AdaptiveCognitiveEngine.instance.observe(CognitiveMetricRecord(
        sessionEventId: 'evt_$i',
        contentKey: 'word',
        responseLatency: const Duration(milliseconds: 1000),
        hesitationTaps: 0,
        isCorrect: true,
        recordedAt: DateTime.now(),
        isCefrVerified: true,
      ));
    }
    final decision = AdaptiveCognitiveEngine.instance.evaluateDetailedState();
    expect(decision.action, AdaptationAction.deepenLinguisticChallenge);
    expect(decision.reason, isA<ConsistentMastery>());
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

  test('Isolates pairs', () {
    // English pair - fatigue
    for (int i = 0; i < 5; i++) {
      AdaptiveCognitiveEngine.instance.observe(CognitiveMetricRecord(
        sessionEventId: 'evt_$i',
        contentKey: 'word',
        responseLatency: const Duration(seconds: 6),
        hesitationTaps: 2,
        isCorrect: false,
        recordedAt: DateTime.now(),
        targetLanguageCode: 'en',
      ));
    }

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

    final decisionEn = AdaptiveCognitiveEngine.instance.evaluateDetailedState(targetLanguageCode: 'en');
    expect(decisionEn.action, AdaptationAction.reduceExtraneousLoad);

    final decisionDe = AdaptiveCognitiveEngine.instance.evaluateDetailedState(targetLanguageCode: 'de');
    expect(decisionDe.action, AdaptationAction.deepenLinguisticChallenge);
  });

  test('Hysteresis prevents oscillation', () {
    // Trigger fatigue
    for (int i = 0; i < 5; i++) {
      AdaptiveCognitiveEngine.instance.observe(CognitiveMetricRecord(
        sessionEventId: 'evt_$i',
        contentKey: 'word',
        responseLatency: const Duration(seconds: 6),
        hesitationTaps: 2,
        isCorrect: false,
        recordedAt: DateTime.now(),
      ));
    }

    // Base time
    final baseTime = DateTime(2023, 1, 1, 12, 0, 0);

    final decision1 = AdaptiveCognitiveEngine.instance.evaluateDetailedState(currentTime: baseTime);
    expect(decision1.action, AdaptationAction.reduceExtraneousLoad);
    expect(decision1.reason, isA<FatigueDetected>());

    // Attempt state change within hysteresis window (e.g. 1 minute later)
    for (int i = 0; i < 5; i++) {
      AdaptiveCognitiveEngine.instance.observe(CognitiveMetricRecord(
        sessionEventId: 'evt_$i',
        contentKey: 'word',
        responseLatency: const Duration(milliseconds: 1000),
        hesitationTaps: 0,
        isCorrect: true,
        recordedAt: DateTime.now(),
        isCefrVerified: true,
      ));
    }

    final closeTime = baseTime.add(const Duration(minutes: 1));
    final decision2 = AdaptiveCognitiveEngine.instance.evaluateDetailedState(currentTime: closeTime);

    // Should stay reduced load due to hysteresis
    expect(decision2.action, AdaptationAction.reduceExtraneousLoad);
    expect(decision2.reason, isA<HysteresisCoolDown>());

    // Attempt state change outside hysteresis window (e.g. 6 minutes later)
    final farTime = baseTime.add(const Duration(minutes: 6));
    final decision3 = AdaptiveCognitiveEngine.instance.evaluateDetailedState(currentTime: farTime);

    // Should now change to deepen challenge
    expect(decision3.action, AdaptationAction.deepenLinguisticChallenge);
    expect(decision3.reason, isA<ConsistentMastery>());
  });

  test('CEFR unverified prevention', () {
    for (int i = 0; i < 5; i++) {
      AdaptiveCognitiveEngine.instance.observe(CognitiveMetricRecord(
        sessionEventId: 'evt_$i',
        contentKey: 'word',
        responseLatency: const Duration(milliseconds: 1000),
        hesitationTaps: 0,
        isCorrect: true,
        recordedAt: DateTime.now(),
        isCefrVerified: false,
      ));
    }
    final decision = AdaptiveCognitiveEngine.instance.evaluateDetailedState();
    expect(decision.action, AdaptationAction.maintainFlow);
    expect(decision.reason, isA<UnverifiedCEFR>());
  });

  test('CEFR verified allows deepening', () {
    for (int i = 0; i < 5; i++) {
      AdaptiveCognitiveEngine.instance.observe(CognitiveMetricRecord(
        sessionEventId: 'evt_$i',
        contentKey: 'word',
        responseLatency: const Duration(milliseconds: 1000),
        hesitationTaps: 0,
        isCorrect: true,
        recordedAt: DateTime.now(),
        isCefrVerified: true,
      ));
    }
    final decision = AdaptiveCognitiveEngine.instance.evaluateDetailedState();
    expect(decision.action, AdaptationAction.deepenLinguisticChallenge);
    expect(decision.reason, isA<ConsistentMastery>());
  });
}
