/// Task 1065: On-device ML neural inference duty-cycle throttle
class NeuralInferenceStrideLimiter {
  int strideDelayMs = 0;
  void throttleDutyCycle(bool highTemp) => strideDelayMs = highTemp ? 100 : 0;
}
