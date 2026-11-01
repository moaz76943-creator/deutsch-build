enum ThermalThrottlingLevel { normal, warm, critical }

class BatteryAdaptiveInferenceThrottle {
  int computeTargetSampleRate(int batteryPercent, ThermalThrottlingLevel thermal) {
    if (thermal == ThermalThrottlingLevel.critical || batteryPercent < 15) return 16000;
    if (batteryPercent < 30) return 22050;
    return 24000;
  }
}
