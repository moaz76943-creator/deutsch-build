/// Task 1048: Rapid volume change debouncer preventing audio distortion
class VolumeEventDebouncer {
  int lastChangeTimestamp = 0;
  bool shouldProcess(int now) {
    if (now - lastChangeTimestamp > 50) {
      lastChangeTimestamp = now;
      return true;
    }
    return false;
  }
}
