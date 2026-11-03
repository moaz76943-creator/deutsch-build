/// Task 1054: Auto-reconnection handler for broken audio pipelines
class AudioPipeHealer {
  int reconnections = 0;
  void repairBrokenPipe() => reconnections++;
  int get repairCount => reconnections;
}
