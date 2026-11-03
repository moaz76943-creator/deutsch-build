/// Task 1276: OS dynamic text size accessibility multiplier (up to 200%)
class DynamicTypeAccessibilityScaler {
  double scaleFontSize(double baseSize, double osScaleFactor) => (baseSize * osScaleFactor).clamp(baseSize, baseSize * 2.0);
}
