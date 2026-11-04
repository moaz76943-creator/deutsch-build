/// Task 1402: Bayesian Knowledge Tracing (BKT) engine
class BktMasteryModel {
  double updateMastery(double pMastery, bool isCorrect) => isCorrect ? (pMastery * 0.9) / (pMastery * 0.9 + 0.1) : (pMastery * 0.2) / 0.8;
}
