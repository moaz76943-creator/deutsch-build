/// Task 1268: Harmonizes x-height and cap-height across scripts
class ScriptHeightHarmonizer {
  double calculateScaleFactor(double targetCap, double fontCap) => fontCap > 0 ? targetCap / fontCap : 1.0;
}
