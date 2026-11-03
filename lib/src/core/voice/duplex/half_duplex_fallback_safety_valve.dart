/// Task 1128: Automatic half-duplex toggle on low-end hardware
class HalfDuplexSafetyValve {
  bool isHalfDuplexEnforced = false;
  void evaluateCapability(int ramMb) => isHalfDuplexEnforced = ramMb < 1500;
}
