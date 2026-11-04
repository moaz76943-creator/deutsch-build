/// Task 1967: Real-time Words-Per-Minute (WPM) articulatory pace calibrator
class ArticulationRateCalibrator {
  double computeWpm(int syllables, int durationMs) => durationMs > 0 ? (syllables / 1.5) / (durationMs / 60000.0) : 120.0;
}
