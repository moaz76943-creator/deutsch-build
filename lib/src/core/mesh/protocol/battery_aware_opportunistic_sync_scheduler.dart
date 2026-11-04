/// Task 1517: Opportunistic background sync scheduler pausing on low battery
class OpportunisticSyncScheduler {
  bool canSync(int batteryLevel, bool isCharging) => isCharging || batteryLevel >= 35;
}
