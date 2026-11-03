/// Task 1078: Sensory polling rate throttling based on ambient light stability
class AmbientSensorPowerGate {
  int pollingIntervalMs = 1000;
  void adaptInterval(bool isStable) => pollingIntervalMs = isStable ? 5000 : 1000;
}
