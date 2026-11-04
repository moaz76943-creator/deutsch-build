/// Task 1632: Haptic pulsator encoding consonant gemination closure duration
class GeminateHapticPulsator {
  int calculatePulseMs(int closureDurationMs) => closureDurationMs.clamp(50, 300);
}
