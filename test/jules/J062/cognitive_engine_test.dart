import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cognitive/adaptive_cognitive_engine.dart';
import 'package:deutsch_bilarabi/core/cognitive/cognitive_metric_record.dart';

void main() {
  group('AdaptiveCognitiveEngine Tests', () {
    late AdaptiveCognitiveEngine engine;

    setUp(() {
      engine = AdaptiveCognitiveEngine.instance;
      // Clear specific pairs we might use
      engine.clearSession(languagePairKey: 'ar-de');
      engine.clearSession(languagePairKey: 'en-es');
      engine.clearSession(languagePairKey: 'default');
    });

    test('cold start default behavior returns maintainFlow and coldStart reason', () {
      final decision = engine.evaluateDecision(languagePairKey: 'ar-de');
      expect(decision.action, AdaptationAction.maintainFlow);
      expect(decision.reason, AdaptationReason.coldStart);
    });

    test('negative latency and negative hesitation are normalized and handled gracefully', () {
      final record = CognitiveMetricRecord(
        sessionEventId: 'ev1',
        contentKey: 'ck1',
        responseLatency: const Duration(seconds: -10),
        hesitationTaps: -5,
        isCorrect: true,
        recordedAt: DateTime.now(),
        languagePairKey: 'ar-de',
      );

      expect(record.cognitiveStrainIndex, 0.0);
      engine.observe(record);

      final decision = engine.evaluateDecision(languagePairKey: 'ar-de');
      expect(decision.action, AdaptationAction.maintainFlow);
    });

    test('independent tracking of distinct languagePairKeys', () {
      // Simulate poor performance in ar-de
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'evt_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 10),
          hesitationTaps: 2,
          isCorrect: false,
          recordedAt: DateTime.now(),
          languagePairKey: 'ar-de',
        ));
      }

      // Simulate excellent performance in en-es
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'evt2_$i',
          contentKey: 'ck2_$i',
          responseLatency: const Duration(milliseconds: 1000),
          hesitationTaps: 0,
          isCorrect: true,
          recordedAt: DateTime.now(),
          languagePairKey: 'en-es',
        ));
      }

      final decisionArDe = engine.evaluateDecision(languagePairKey: 'ar-de');
      expect(decisionArDe.action, AdaptationAction.reduceExtraneousLoad);
      expect(decisionArDe.reason, AdaptationReason.sustainedStrain);

      final decisionEnEs = engine.evaluateDecision(languagePairKey: 'en-es');
      expect(decisionEnEs.action, AdaptationAction.deepenLinguisticChallenge);
      expect(decisionEnEs.reason, AdaptationReason.excellentFlow);
    });

    test('hysteresis keeps reduceExtraneousLoad until strain is sufficiently low', () {
      // 1. Induce high strain
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'evt_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(seconds: 10),
          hesitationTaps: 2,
          isCorrect: false,
          recordedAt: DateTime.now(),
          languagePairKey: 'ar-de',
        ));
      }
      expect(engine.evaluateDecision(languagePairKey: 'ar-de').action, AdaptationAction.reduceExtraneousLoad);

      // 2. Add a medium strain record (avg strain will drop slightly but > 0.3)
      engine.observe(CognitiveMetricRecord(
          sessionEventId: 'evt_med',
          contentKey: 'ck_med',
          responseLatency: const Duration(seconds: 4), // +0.2
          hesitationTaps: 0, // +0
          isCorrect: false, // +0.3
          recordedAt: DateTime.now(),
          languagePairKey: 'ar-de',
      ));

      // Still reducing load
      final decisionMid = engine.evaluateDecision(languagePairKey: 'ar-de');
      expect(decisionMid.action, AdaptationAction.reduceExtraneousLoad);
      expect(decisionMid.reason, AdaptationReason.sustainedStrain);

      // 3. Add many excellent records to push average strain below 0.3
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'evt_good_$i',
          contentKey: 'ck_good_$i',
          responseLatency: const Duration(milliseconds: 1000),
          hesitationTaps: 0,
          isCorrect: true,
          recordedAt: DateTime.now(),
          languagePairKey: 'ar-de',
        ));
      }

      final decisionRecovered = engine.evaluateDecision(languagePairKey: 'ar-de');
      expect(decisionRecovered.action, AdaptationAction.maintainFlow);
      expect(decisionRecovered.reason, AdaptationReason.recovering);
    });

    test('drops extreme records with very high latency', () {
      engine.observe(CognitiveMetricRecord(
        sessionEventId: 'ev1',
        contentKey: 'ck1',
        responseLatency: const Duration(hours: 2), // Should be dropped
        hesitationTaps: 5,
        isCorrect: false,
        recordedAt: DateTime.now(),
        languagePairKey: 'ar-de',
      ));

      // Should be treated as cold start since the record was ignored
      final decision = engine.evaluateDecision(languagePairKey: 'ar-de');
      expect(decision.action, AdaptationAction.maintainFlow);
      expect(decision.reason, AdaptationReason.coldStart);
    });

    test('deepenLinguisticChallenge hysteresis immediately drops on struggle', () {
      // 1. Establish deepen state
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'evt_$i',
          contentKey: 'ck_$i',
          responseLatency: const Duration(milliseconds: 1000),
          hesitationTaps: 0,
          isCorrect: true,
          recordedAt: DateTime.now(),
          languagePairKey: 'ar-de',
        ));
      }
      expect(engine.evaluateDecision(languagePairKey: 'ar-de').action, AdaptationAction.deepenLinguisticChallenge);

      // 2. Single hesitation or slight latency increase
      engine.observe(CognitiveMetricRecord(
          sessionEventId: 'evt_struggle',
          contentKey: 'ck_struggle',
          responseLatency: const Duration(seconds: 4), // Over threshold
          hesitationTaps: 2, // Over threshold
          isCorrect: true,
          recordedAt: DateTime.now(),
          languagePairKey: 'ar-de',
      ));

      final decision = engine.evaluateDecision(languagePairKey: 'ar-de');
      expect(decision.action, AdaptationAction.maintainFlow);
      expect(decision.reason, AdaptationReason.recovering);
    });
  });
}
