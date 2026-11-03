/// Task 1116: Playback rate controller (0.5x to 2.0x) preserving pitch
class SyllableRateController {
  double playbackRate = 1.0;
  void setRate(double rate) => playbackRate = rate.clamp(0.5, 2.0);
}
