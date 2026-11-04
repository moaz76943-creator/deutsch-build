/// Task 1793: Subword token entropy and uncertainty estimator
class SubwordUncertaintyCalibrator {
  List<double> calculateTokenConfidences(List<double> logProbs) => logProbs.map((p) => p.abs()).toList();
}
