/// Task 2042: Collaborative vocabulary difficulty estimator across offline classroom peers
class VocabularyDifficultyEstimator {
  double estimateDifficulty(int failureCount, int totalReviews) => totalReviews > 0 ? (failureCount / totalReviews) * 10.0 : 5.0;
}
