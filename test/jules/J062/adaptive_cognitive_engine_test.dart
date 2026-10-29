import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/cognitive/adaptive_cognitive_engine.dart';
import '../../../lib/core/cognitive/cognitive_metric_record.dart';

void main() {
  late AdaptiveCognitiveEngine engine;

  setUp(() {
    engine = AdaptiveCognitiveEngine.instance;
    engine.clearSession();
  });

  CognitiveMetricRecord createRecord({
    String pairKey = 'en_ar',
    bool isCorrect = true,
    int latencyMs = 1000,
    int hesitationTaps = 0,
    int? srsGrade,
    String? cefrLevel,
    bool cefrVerified = false,
  }) {
    return CognitiveMetricRecord(
      sessionEventId: 'ev_123',
      contentKey: 'word_1',
      responseLatency: Duration(milliseconds: latencyMs),
      isCorrect: isCorrect,
      hesitationTaps: hesitationTaps,
      recordedAt: DateTime.now(),
      pairKey: pairKey,
      srsGrade: srsGrade,
      cefrLevel: cefrLevel,
      cefrVerified: cefrVerified,
    );
  }

  test('cold start should return maintainFlow', () {
    final decision = engine.evaluateDetailedState(pairKey: 'new_pair');
    expect(decision.action, AdaptationAction.maintainFlow);
    expect(decision.reason, AdaptationReason.coldStart);
  });

  test('fatigue detected with high latency', () {
    engine.observe(createRecord(latencyMs: 6000));
    engine.observe(createRecord(latencyMs: 6000));
    engine.observe(createRecord(latencyMs: 6000));

    final decision = engine.evaluateDetailedState(pairKey: 'en_ar');
    expect(decision.action, AdaptationAction.reduceExtraneousLoad);
    expect(decision.reason, AdaptationReason.fatigueDetected);
  });

  test('repeated mistakes triggers reduceExtraneousLoad', () {
    engine.observe(createRecord(isCorrect: false));
    engine.observe(createRecord(isCorrect: false));
    engine.observe(createRecord(isCorrect: false));

    final decision = engine.evaluateDetailedState(pairKey: 'en_ar');
    expect(decision.action, AdaptationAction.reduceExtraneousLoad);
    expect(decision.reason, AdaptationReason.repeatedMistakes);
  });

  test('high strain from multiple factors', () {
    engine.observe(createRecord(hesitationTaps: 2, latencyMs: 3500, srsGrade: 0));
    engine.observe(createRecord(hesitationTaps: 2, latencyMs: 3500, srsGrade: 0));

    final decision = engine.evaluateDetailedState(pairKey: 'en_ar');
    expect(decision.action, AdaptationAction.reduceExtraneousLoad);
    expect(decision.reason, AdaptationReason.highStrain);
  });

  test('mastery detected with fast and correct responses', () {
    engine.observe(createRecord(latencyMs: 1000, srsGrade: 3));
    engine.observe(createRecord(latencyMs: 1200, srsGrade: 3));
    engine.observe(createRecord(latencyMs: 1100, srsGrade: 3));

    final decision = engine.evaluateDetailedState(pairKey: 'en_ar');
    expect(decision.action, AdaptationAction.deepenLinguisticChallenge);
    expect(decision.reason, AdaptationReason.masteryDetected);
  });

  test('hysteresis prevents rapid oscillation', () {
    // Establish state 1
    engine.observe(createRecord(latencyMs: 6000));
    engine.observe(createRecord(latencyMs: 6000));
    engine.observe(createRecord(latencyMs: 6000));
    final dec1 = engine.evaluateDetailedState(pairKey: 'en_ar');
    expect(dec1.action, AdaptationAction.reduceExtraneousLoad);

    // Simulate fast responses to push out the fatigue records from the window
    engine.observe(createRecord(latencyMs: 1000));
    engine.observe(createRecord(latencyMs: 1000));
    engine.observe(createRecord(latencyMs: 1000));
    // Now window has [6000, 6000, 1000, 1000, 1000], average strain drops,
    // fatigue is no longer met, mastery is met. But hysteresis should block it.
    final dec2 = engine.evaluateDetailedState(pairKey: 'en_ar');

    expect(dec2.action, AdaptationAction.reduceExtraneousLoad);
    expect(dec2.reason, AdaptationReason.hysteresisActive);
  });

  test('noisy metrics detected', () {
    engine.observe(createRecord(latencyMs: 6000, isCorrect: false)); // strain high
    engine.observe(createRecord(latencyMs: 500, isCorrect: true, srsGrade: 3)); // strain 0
    engine.observe(createRecord(latencyMs: 6000, isCorrect: false)); // strain high
    engine.observe(createRecord(latencyMs: 500, isCorrect: true, srsGrade: 3)); // strain 0

    final decision = engine.evaluateDetailedState(pairKey: 'en_ar');
    expect(decision.reason, AdaptationReason.noisyMetrics);
    expect(decision.action, AdaptationAction.maintainFlow);
  });

  test('pair isolation works correctly', () {
    engine.observe(createRecord(pairKey: 'en_ar', latencyMs: 1000));
    engine.observe(createRecord(pairKey: 'en_ar', latencyMs: 1000));
    engine.observe(createRecord(pairKey: 'en_ar', latencyMs: 1000));

    engine.observe(createRecord(pairKey: 'fr_ar', latencyMs: 6000));
    engine.observe(createRecord(pairKey: 'fr_ar', latencyMs: 6000));
    engine.observe(createRecord(pairKey: 'fr_ar', latencyMs: 6000));

    final enArDecision = engine.evaluateDetailedState(pairKey: 'en_ar');
    expect(enArDecision.action, AdaptationAction.deepenLinguisticChallenge);

    final frArDecision = engine.evaluateDetailedState(pairKey: 'fr_ar');
    expect(frArDecision.action, AdaptationAction.reduceExtraneousLoad);
  });

  test('malformed records are ignored', () {
    engine.observe(createRecord(latencyMs: -100)); // malformed latency
    engine.observe(createRecord(hesitationTaps: -1)); // malformed hesitation
    engine.observe(createRecord(srsGrade: 5)); // malformed grade

    final decision = engine.evaluateDetailedState(pairKey: 'en_ar');
    expect(decision.reason, AdaptationReason.coldStart);
  });

  test('cefrLevel is only saved if verified', () {
    engine.observe(createRecord(cefrLevel: 'A1', cefrVerified: false));
    expect(engine.getVerifiedCefr('en_ar'), isNull);

    engine.observe(createRecord(cefrLevel: 'A2', cefrVerified: true));
    expect(engine.getVerifiedCefr('en_ar'), 'A2');
  });

  test('daily updates are idempotent', () {
    final history = [
      createRecord(latencyMs: 1000),
      createRecord(latencyMs: 1000),
      createRecord(latencyMs: 1000),
    ];

    engine.processDailyUpdates(DateTime.now(), history);
    final decision1 = engine.evaluateDetailedState(pairKey: 'en_ar');

    engine.processDailyUpdates(DateTime.now(), history);
    final decision2 = engine.evaluateDetailedState(pairKey: 'en_ar');

    expect(decision1.action, decision2.action);
    expect(decision1.reason, decision2.reason);
  });
}
