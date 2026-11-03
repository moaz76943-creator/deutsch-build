/// Task 1052: Software AEC gain controller & double-talk acoustic suppressor
class AecGainController {
  double suppressionFactor = 0.8;
  void setDoubleTalkMode(bool active) => suppressionFactor = active ? 0.95 : 0.8;
  double get effectiveGain => 1.0 - suppressionFactor;
}
