/// Task 1111: Boundary transition smoother between adjacent disparate phonemes
class CoarticulationSmoother {
  double smoothBoundary(double p1, double p2, double t) => (1.0 - t) * p1 + t * p2;
}
