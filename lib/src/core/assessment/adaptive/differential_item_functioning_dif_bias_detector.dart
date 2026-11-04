/// Task 1413: Differential Item Functioning (DIF) detector for cultural bias
class DifBiasDetector {
  bool hasItemBias(double focalDifficulty, double referenceDifficulty) => (focalDifficulty - referenceDifficulty).abs() > 0.45;
}
