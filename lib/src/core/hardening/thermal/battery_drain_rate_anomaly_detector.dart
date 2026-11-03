/// Task 1072: Real-time battery % drain rate anomaly detector
class BatteryDrainAnomalyDetector {
  double drainRatePerHour = 2.5;
  void recordDrain(double rate) => drainRatePerHour = rate;
  bool get isAbnormalDrain => drainRatePerHour > 12.0;
}
