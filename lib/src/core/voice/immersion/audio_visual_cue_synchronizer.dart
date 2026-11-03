/// Task 1184: Aligns spatial audio events with onscreen dialogue prompts
class AudioVisualCueSynchronizer {
  int cueOffsetMs = 0;
  void syncCue(int audioMs, int visualMs) => cueOffsetMs = visualMs - audioMs;
}
