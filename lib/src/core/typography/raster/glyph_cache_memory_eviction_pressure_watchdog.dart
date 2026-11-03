/// Task 1234: Monitors texture memory consumption & triggers atlas compaction
class GlyphMemoryWatchdog {
  int currentAtlasBytes = 0;
  bool shouldEvict(int threshold) => currentAtlasBytes > threshold;
}
