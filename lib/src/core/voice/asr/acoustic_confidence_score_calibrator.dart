/// Task 1145: Posterior phoneme probability confidence scoring
class AcousticConfidenceCalibrator {
  double calibrateScore(double rawLogit) => (1.0 / (1.0 + rawLogit.abs())).clamp(0.0, 1.0);
}
