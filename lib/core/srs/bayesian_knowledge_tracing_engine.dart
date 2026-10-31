class BktSkillParameters {
  final double pInit;   // P(L0): الاحتمال المبدئي للمعرفة
  final double pTransit;// P(T): معدل الانتقال إلى الإتقان بعد التمرين
  final double pGuess;  // P(G): احتمالية التخمين بالصدفة
  final double pSlip;   // P(S): احتمالية الزلل والخطأ العفوي رغم الإتقان

  const BktSkillParameters({
    this.pInit = 0.15,
    this.pTransit = 0.20,
    this.pGuess = 0.15,
    this.pSlip = 0.08,
  });
}

class BktUpdateOutcome {
  final double posteriorMastery; // P(Lt+1): احتمالية الإتقان المحدثة
  final bool isMastered;         // هل تجاوزت عتبة الإتقان 95%؟
  final double predictedCorrect; // احتمالية تقديم إجابة صحيحة في الخطوة القادمة

  const BktUpdateOutcome({
    required this.posteriorMastery,
    required this.isMastered,
    required this.predictedCorrect,
  });
}

/// Offline probabilistic cognitive engine tracking skill mastery using standard Bayesian Knowledge Tracing (Corbett & Anderson).
class BayesianKnowledgeTracingEngine {
  final double masteryThreshold; // عتبة الإتقان (افتراضياً 95%)

  const BayesianKnowledgeTracingEngine({this.masteryThreshold = 0.95});

  /// حساب التحديث البايزي لاحتمالية الإتقان بناءً على صحة إجابة المتعلم
  BktUpdateOutcome updateKnowledge({
    required double priorMastery, // P(Lt-1)
    required bool isCorrect,
    BktSkillParameters params = const BktSkillParameters(),
  }) {
    double pLearnedGivenObs;

    if (isCorrect) {
      // قاعدة بايز للإجابة الصحيحة: عزل أثر التخمين (Guess)
      final numerator = priorMastery * (1.0 - params.pSlip);
      final denominator = numerator + (1.0 - priorMastery) * params.pGuess;
      pLearnedGivenObs = denominator > 0.0 ? numerator / denominator : priorMastery;
    } else {
      // قاعدة بايز للإجابة الخاطئة: عزل أثر الزلل (Slip)
      final numerator = priorMastery * params.pSlip;
      final denominator = numerator + (1.0 - priorMastery) * (1.0 - params.pGuess);
      pLearnedGivenObs = denominator > 0.0 ? numerator / denominator : priorMastery;
    }

    // معادلة الانتقال بعد التمرين: P(Lt) = P(Lt|Obs) + (1 - P(Lt|Obs)) * P(T)
    final posterior = pLearnedGivenObs + (1.0 - pLearnedGivenObs) * params.pTransit;
    final clampedPosterior = posterior.clamp(0.01, 0.999);

    // التنبؤ باحتمالية صحة الإجابة التالية: P(Correct) = P(L)*(1-S) + (1-P(L))*G
    final nextPredicted = clampedPosterior * (1.0 - params.pSlip) +
        (1.0 - clampedPosterior) * params.pGuess;

    return BktUpdateOutcome(
      posteriorMastery: double.parse(clampedPosterior.toStringAsFixed(3)),
      isMastered: clampedPosterior >= masteryThreshold,
      predictedCorrect: double.parse(nextPredicted.toStringAsFixed(3)),
    );
  }
}
