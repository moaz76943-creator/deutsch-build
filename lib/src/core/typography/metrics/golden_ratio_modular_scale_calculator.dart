/// Task 1261: Modular typographic scale using Golden Ratio & Perfect Fourth
class ModularScaleCalculator {
  static const double goldenRatio = 1.61803398875;
  double getScale(double base, int step) => base * (step > 0 ? goldenRatio : 1.0);
}
