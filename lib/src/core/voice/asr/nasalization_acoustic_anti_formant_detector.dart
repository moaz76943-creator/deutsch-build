/// Task 1152: Anti-formant detector identifying vowel nasalization
class NasalizationAntiFormantDetector {
  bool isNasalized(double antiFormantDepthDb) => antiFormantDepthDb > 6.0;
}
