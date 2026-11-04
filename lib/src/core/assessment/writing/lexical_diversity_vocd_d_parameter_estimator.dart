/// Task 1442: vocd-D parameter estimator for vocabulary diversity
class VocdDEstimator {
  double estimateD(int uniqueTokens, int totalTokens) => totalTokens > 0 ? (uniqueTokens / totalTokens) * 100.0 : 0.0;
}
