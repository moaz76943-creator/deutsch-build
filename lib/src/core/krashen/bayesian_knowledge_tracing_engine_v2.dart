class BayesianKnowledgeTracingEngineV2 {
  final double pL0, pT, pS, pG;
  const BayesianKnowledgeTracingEngineV2({this.pL0 = 0.10, this.pT = 0.15, this.pS = 0.08, this.pG = 0.20});

  double updateMastery(double pLPrev, bool isCorrect) {
    double pGivenObs;
    if (isCorrect) {
      final num = pLPrev * (1.0 - pS);
      pGivenObs = num / (num + ((1.0 - pLPrev) * pG));
    } else {
      final num = pLPrev * pS;
      pGivenObs = num / (num + ((1.0 - pLPrev) * (1.0 - pG)));
    }
    return (pGivenObs + (1.0 - pGivenObs) * pT).clamp(0.001, 0.999);
  }
}
