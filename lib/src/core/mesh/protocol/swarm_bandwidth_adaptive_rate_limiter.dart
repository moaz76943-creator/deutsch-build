/// Task 1506: Local mesh bandwidth throttle preventing network congestion
class SwarmRateLimiter {
  int getMaxChunkBytes(bool isBatterySaver) => isBatterySaver ? 64 * 1024 : 512 * 1024;
}
