/// Task 1465: Ensures distractors are semantically plausible
class DistractorCosineGatekeeper {
  bool isPlausible(double cosineSim) => cosineSim >= 0.45 && cosineSim <= 0.85;
}
