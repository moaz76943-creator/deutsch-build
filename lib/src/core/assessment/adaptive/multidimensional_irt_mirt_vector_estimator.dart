/// Task 1414: Multidimensional IRT (MIRT) vector estimator
class MirtVectorEstimator {
  List<double> updateThetaVector(List<double> thetas, int skillDim, bool isCorrect) {
    List<double> updated = List.from(thetas);
    updated[skillDim] += isCorrect ? 0.15 : -0.15;
    return updated;
  }
}
