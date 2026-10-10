import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cognitive/cognitive_metric_record.dart';
import 'package:deutsch_bilarabi/core/cognitive/adaptive_cognitive_engine.dart';

void main() {
  group('Adaptive Cognitive Engine Tests', () {
    late AdaptiveCognitiveEngine engine;

    setUp(() {
      engine = AdaptiveCognitiveEngine.instance;
      engine.clearSession();
    });

    test('يكتشف الإرهاق والتردد ويوجه لتبسيط الواجهة وتهدئة الحمل المعرفي', () {
      // محاكاة 5 إجابات بطيئة ومعقدة مع أخطاء
      for (int i = 0; i < 5; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'EVT_$i',
          contentKey: 'CARD_$i',
          responseLatency: const Duration(milliseconds: 6000),
          hesitationTaps: 2,
          isCorrect: false,
          recordedAt: DateTime.now(),
        ));
      }

      final action = engine.evaluateState();
      expect(action, AdaptationAction.reduceExtraneousLoad);
    });

    test('يكتشف التمكن والسرعة ويوجه لتعميق التحدي اللغوي تلقائياً', () {
      // محاكاة إجابات صحيحة وسريعة جداً
      for (int i = 0; i < 4; i++) {
        engine.observe(CognitiveMetricRecord(
          sessionEventId: 'EVT_FAST_$i',
          contentKey: 'CARD_FAST_$i',
          responseLatency: const Duration(milliseconds: 1200),
          hesitationTaps: 0,
          isCorrect: true,
          recordedAt: DateTime.now(),
        ));
      }

      final action = engine.evaluateState();
      expect(action, AdaptationAction.deepenLinguisticChallenge);
    });
  });
}
