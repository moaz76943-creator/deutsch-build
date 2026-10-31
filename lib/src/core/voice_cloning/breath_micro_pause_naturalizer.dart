class BreathMicroPauseNaturalizer {
  List<double> injectBreathPause(List<double> samples, int pauseSamples) {
    return [...samples, ...List<double>.filled(pauseSamples, 0.005)];
  }
}
