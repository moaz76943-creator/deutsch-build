/// Task 1063: Low-power background sync deferral queue during battery saver mode
class BackgroundSyncDeferralQueue {
  int deferredTasks = 0;
  void deferTask() => deferredTasks++;
  void flushQueue() => deferredTasks = 0;
}
