/// Task 1075: Flash storage wear-leveling & dirty page write coalescer
class FlashWearCoalescer {
  int dirtyPagesCount = 0;
  void markDirty() => dirtyPagesCount++;
  bool get shouldFlush => dirtyPagesCount >= 16;
  void flush() => dirtyPagesCount = 0;
}
