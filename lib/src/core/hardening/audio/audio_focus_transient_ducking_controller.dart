/// Task 1041: Audio focus ducking & transient interruption attenuation manager
class AudioFocusDuckingController {
  double currentVolume = 1.0;
  void duckVolume() => currentVolume = 0.2;
  void restoreVolume() => currentVolume = 1.0;
  bool get isDucked => currentVolume < 1.0;
}
