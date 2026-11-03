/// Task 1126: Playout vs capture hardware timestamp synchronizer
class AudioTimestampSyncBuffer {
  int syncOffsetMs = 0;
  void calibrate(int playoutTs, int captureTs) => syncOffsetMs = captureTs - playoutTs;
}
