/// Task 1223: Quadratic and cubic Bézier curve subdivider and tessellator
class BezierCurveTessellator {
  List<double> evaluateQuadratic(double p0, double p1, double p2, double t) {
    double u = 1.0 - t;
    return [u * u * p0 + 2.0 * u * t * p1 + t * t * p2];
  }
}
