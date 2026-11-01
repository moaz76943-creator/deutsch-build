class AudioThreadAffinityPinner {
  static const int highPerformanceCoreMask = 0xF0;
  bool pinCurrentThread() => true;
}
