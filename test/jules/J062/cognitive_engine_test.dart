import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cognitive/adaptive_cognitive_engine.dart';
import 'package:deutsch_bilarabi/core/cognitive/cognitive_metric_record.dart';

void main() {
  late AdaptiveCognitiveEngine engine;

  setUp(() {
    engine = AdaptiveCognitiveEngine.instance;
    engine.clearSession();
  });

  test('Fallback when empty', () {
    final decision = engine.evaluateDetailedState();
    expect(decision.action, AdaptationAction.maintainFlow);
    expect(decision.reason, isA<InsufficientData>());
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
        targetLanguageCode: 'default_pair',
      ));
    }

    final decision = engine.evaluateDetailedState();
    expect(decision.action, AdaptationAction.reduceExtraneousLoad);
  });

  test('Hysteresis prevents oscillating difficulty', () {
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

  test('Noisy metrics (negative latency/taps)', () {
    engine.observe(CognitiveMetricRecord(
      sessionEventId: 'noise',
      contentKey: 'ck',
      responseLatency: const Duration(seconds: -10),
      hesitationTaps: -5,
      isCorrect: true,
      recordedAt: DateTime.now(),
    ));
    final decision = engine.evaluateDetailedState();
    expect(decision.action, AdaptationAction.maintainFlow);
    expect(decision.reason, isA<StableFlow>());
  });

  test('Missing/Negative values handled gracefully', () {
    engine.observe(CognitiveMetricRecord(
      sessionEventId: 'evt_1',
      contentKey: 'word',
      responseLatency: const Duration(milliseconds: -1000),
      hesitationTaps: -2,
      isCorrect: true,
      recordedAt: DateTime.now(),
    ));
    final decision = engine.evaluateDetailedState();
    expect(decision.action, AdaptationAction.maintainFlow);
  });

  test('German pair - mastery', () {
    for (int i = 0; i < 5; i++) {
      engine.observe(CognitiveMetricRecord(
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

    final decision = engine.evaluateDetailedState(targetLanguageCode: 'de');
    expect(decision.action, AdaptationAction.deepenLinguisticChallenge);
    expect(decision.reason, isA<ConsistentMastery>());
  });
}
