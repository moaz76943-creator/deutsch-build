/// Task 1476: Effective Reading Rate (ERR) combining WPM speed and accuracy
class EffectiveReadingRateMeter {
  double calculateErr(double wpm, double comprehensionAccuracy) => wpm * (comprehensionAccuracy / 100.0);
}
