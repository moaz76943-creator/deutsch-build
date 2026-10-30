enum SpeakerDemographicGroup {
  childSpeaker,       // F0 ~ 250 - 360 Hz (shorter vocal tract)
  adultFemaleSpeaker, // F0 ~ 180 - 240 Hz
  adultMaleSpeaker,   // F0 ~ 90 - 150 Hz
}

class NormalizedFormantProfile {
  final SpeakerDemographicGroup demographic;
  final double vocalTractWarpingFactorAlpha;
  final double normalizedF1;
  final double normalizedF2;

  const NormalizedFormantProfile({
    required this.demographic,
    required this.vocalTractWarpingFactorAlpha,
    required this.normalizedF1,
    required this.normalizedF2,
  });
}

class AcousticAgeNormalizer {
  static const double canonicalReferenceF0 = 160.0; // Standard acoustic normalization anchor

  const AcousticAgeNormalizer();

  /// Classifies demographic vocal tract scale and computes Vocal Tract Length Normalization (VTLN) factor alpha.
  NormalizedFormantProfile normalizeLearnerFormants({
    required double measuredF0,
    required double rawF1,
    required double rawF2,
  }) {
    SpeakerDemographicGroup group;
    double alpha;

    if (measuredF0 >= 250.0) {
      group = SpeakerDemographicGroup.childSpeaker;
      alpha = 0.85; // Compress higher formants downward
    } else if (measuredF0 >= 170.0) {
      group = SpeakerDemographicGroup.adultFemaleSpeaker;
      alpha = 0.94;
    } else {
      group = SpeakerDemographicGroup.adultMaleSpeaker;
      alpha = 1.08; // Expand formants to reference space
    }

    return NormalizedFormantProfile(
      demographic: group,
      vocalTractWarpingFactorAlpha: alpha,
      normalizedF1: double.parse((rawF1 * alpha).toStringAsFixed(1)),
      normalizedF2: double.parse((rawF2 * alpha).toStringAsFixed(1)),
    );
  }
}
