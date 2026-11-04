/// Task 1627: Modulates tactile pulse amplitudes for primary vs secondary stress
class StressPulseAmplitudeModulator {
  double getPulseIntensity(bool isPrimary) => isPrimary ? 1.0 : 0.45;
}
