import 'package:deutsch_build/core/srs/bayesian_knowledge_tracing_engine.dart';

void main() {
  const engine = BayesianKnowledgeTracingEngine(masteryThreshold: 0.95);
  const params = BktSkillParameters(pInit: 0.20, pTransit: 0.25, pGuess: 0.15, pSlip: 0.08);

  // 1. إجابة أولى صحيحة: يجب أن يرتفع احتمال الإتقان من 0.20 إلى أكثر من 0.60
  final out1 = engine.updateKnowledge(priorMastery: 0.20, isCorrect: true, params: params);
  assert(out1.posteriorMastery > 0.50);
  assert(!out1.isMastered);

  // 2. سلسلة إجابات صحيحة متتالية: يجب أن تصل للمهارة إلى عتبة الإتقان الكامل (Mastered >= 0.95)
  var currentP = out1.posteriorMastery;
  for (int i = 0; i < 4; i++) {
    final nextOut = engine.updateKnowledge(priorMastery: currentP, isCorrect: true, params: params);
    currentP = nextOut.posteriorMastery;
  }
  assert(currentP >= 0.95, 'Failed: Mastery threshold not reached after streak');
  assert(engine.updateKnowledge(priorMastery: currentP, isCorrect: true, params: params).isMastered);

  // 3. إجابة خاطئة ناتجة عن زلل بسيط: لا تهدم الإتقان المرتفع بالكامل بل تخفضه تدريجياً
  final outSlip = engine.updateKnowledge(priorMastery: 0.96, isCorrect: false, params: params);
  assert(outSlip.posteriorMastery > 0.40, 'Failed: Single mistake obliterated established mastery');

  print('Bayesian Knowledge Tracing engine unit assertions passed.');
}
