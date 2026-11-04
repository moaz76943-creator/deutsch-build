/// Task 2046: Differentially private benchmarker comparing mastery velocity with class average
class AnonymizedLearningVelocityBenchmarker {
  double computeVelocityRank(int masteredWords, double classAverage) => classAverage > 0 ? masteredWords / classAverage : 1.0;
}
