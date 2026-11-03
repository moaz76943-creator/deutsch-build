enum HardwareBackend { cpuGeneric, androidNnapi, appleMetal, vulkanCompute }
class CrossPlatformHardwareAccelerationSelector {
  static HardwareBackend selectBackend(bool isAndroid, bool hasNpu) =>
      isAndroid && hasNpu ? HardwareBackend.androidNnapi : HardwareBackend.cpuGeneric;
}
