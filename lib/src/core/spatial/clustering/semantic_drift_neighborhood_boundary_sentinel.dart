/// Task 1668: Guards against semantic drift ensuring correct cluster anchoring
class SemanticDriftSentinel {
  bool isWithinBoundary(double distanceToCentroid, double maxRadius) => distanceToCentroid <= maxRadius;
}
