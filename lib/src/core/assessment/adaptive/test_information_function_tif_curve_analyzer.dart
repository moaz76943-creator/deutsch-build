/// Task 1412: Test Information Function (TIF) curve calculator
class TifCurveAnalyzer {
  double calculateInformation(double theta, double a, double b) {
    double p = 1.0 / (1.0 + (a * (b - theta)).abs());
    return a * a * p * (1.0 - p);
  }
}
