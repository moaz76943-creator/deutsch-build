/// Task 1045: Adaptive ring buffer jitter compensator preventing crackle/underruns
class AudioBufferJitterCompensator {
  int bufferSizeMs = 120;
  void compensateJitter(bool isSlowNetwork) => bufferSizeMs = isSlowNetwork ? 250 : 120;
}
