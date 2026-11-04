/// Task 1834: Isolates crashed subsystem events preventing entire app bus collapse
class SubsystemCrashIsolationSandbox {
  bool executeSafely(Function action) {
    try {
      action();
      return true;
    } catch (_) {
      return false;
    }
  }
}
