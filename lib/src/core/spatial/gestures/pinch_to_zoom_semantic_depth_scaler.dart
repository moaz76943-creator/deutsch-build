/// Task 1641: Pinch-to-zoom gesture scaling semantic depth
class SemanticDepthScaler {
  int getSemanticLevel(double scale) => scale > 2.0 ? 3 : (scale > 1.2 ? 2 : 1);
}
