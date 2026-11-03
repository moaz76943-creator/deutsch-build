/// Task 1044: CPU partial wake-lock watchdog preventing background playback stutter
class BackgroundAudioWakeLockWatchdog {
  bool wakeLockAcquired = false;
  void acquireLock() => wakeLockAcquired = true;
  void releaseLock() => wakeLockAcquired = false;
}
