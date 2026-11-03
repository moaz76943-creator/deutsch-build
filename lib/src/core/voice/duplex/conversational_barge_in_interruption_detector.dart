/// Task 1121: Low-latency user barge-in speech detector triggering audio cut
class BargeInInterruptionDetector {
  bool isBargeInDetected(double micEnergy, bool isAiSpeaking) => isAiSpeaking && micEnergy > -25.0;
}
