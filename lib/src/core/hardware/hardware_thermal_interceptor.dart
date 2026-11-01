class HardwareThermalInterceptor {
  final double criticalTempCelsius;
  const HardwareThermalInterceptor({this.criticalTempCelsius = 48.0});
  bool isThrottlingRequired(double currentTemp) => currentTemp >= criticalTempCelsius;
}
