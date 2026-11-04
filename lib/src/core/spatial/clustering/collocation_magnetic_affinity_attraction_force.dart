/// Task 1673: Simulates magnetic attraction pulling frequent collocates closer
class CollocationMagneticAttractor {
  double computeAttraction(double mutualInfoScore, double currentDist) => (mutualInfoScore / (currentDist * currentDist + 1.0)).clamp(0.0, 2.0);
}
