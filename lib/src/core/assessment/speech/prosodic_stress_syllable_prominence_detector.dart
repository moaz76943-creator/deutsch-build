/// Task 1422: Acoustic energy & pitch contour lexical stress detector
class ProsodicProminenceDetector {
  bool isStressAccurate(double syllableEnergy, double avgEnergy) => syllableEnergy > avgEnergy * 1.25;
}
