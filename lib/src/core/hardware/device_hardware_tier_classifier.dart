enum DeviceHardwareTier { lowEndBudget, midRangeStandard, highEndFlagship }

class DeviceHardwareTierClassifier {
  static DeviceHardwareTier classifyDevice(int totalRamMb) {
    if (totalRamMb < 2500) return DeviceHardwareTier.lowEndBudget;
    if (totalRamMb < 5000) return DeviceHardwareTier.midRangeStandard;
    return DeviceHardwareTier.highEndFlagship;
  }
}
