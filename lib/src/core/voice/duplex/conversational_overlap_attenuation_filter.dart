/// Task 1131: Attenuation filter for AI speech during conversational overlap
class OverlapAttenuationFilter {
  double currentAttenuation = 0.0;
  void applyAttenuation(bool overlap) => currentAttenuation = overlap ? 0.25 : 1.0;
  double get effectiveGain => currentAttenuation;
}
