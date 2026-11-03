/// Task 1083: Rapid boot crash counter triggering minimal safe mode
class BootLoopSafeModeActivator {
  int consecutiveCrashes = 0;
  void recordBootCrash() => consecutiveCrashes++;
  void recordSuccessfulBoot() => consecutiveCrashes = 0;
  bool get shouldEnterSafeMode => consecutiveCrashes >= 3;
}
