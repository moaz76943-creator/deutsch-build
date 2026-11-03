/// Task 1104: Continuous fundamental frequency (F0) prosody smoother
class PitchContourInterpolator {
  double smoothF0(double prev, double curr) => (prev * 0.3) + (curr * 0.7);
}
