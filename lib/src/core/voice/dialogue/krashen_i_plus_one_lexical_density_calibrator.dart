/// Task 1161: Lexical density calibrator (95% known + 5% i+1 target)
class KrashenDensityCalibrator {
  bool isOptimalDensity(int knownWords, int newWords) {
    int total = knownWords + newWords;
    if (total == 0) return true;
    double newRatio = newWords / total;
    return newRatio >= 0.03 && newRatio <= 0.08;
  }
}
