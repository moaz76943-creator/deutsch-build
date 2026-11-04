/// Task 2016: Power-aware governor duty-cycling radios to consume <1% battery per 8h
class MeshPowerGovernor {
  bool isDutyCycleActive(int batteryPercent) => batteryPercent < 20;
}
