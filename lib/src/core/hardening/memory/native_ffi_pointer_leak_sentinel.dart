class NativeFfiPointerLeakSentinel {
  int activePointers = 0;
  void trackAlloc() => activePointers++;
  void trackFree() => activePointers = activePointers > 0 ? activePointers - 1 : 0;
}
