/// Task 1061: Device thermal throttling state monitor & frequency scaler
class CpuThermalMonitor {
  String thermalStatus = 'NORMAL';
  void updateThermalState(String state) => thermalStatus = state;
  bool get isThrottled => thermalStatus == 'SEVERE' || thermalStatus == 'CRITICAL';
}
