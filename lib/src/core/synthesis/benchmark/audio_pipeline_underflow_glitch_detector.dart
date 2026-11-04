/// Task 1865: Detects audio frame buffer underruns and pops during duplex speech
class AudioGlitchDetector {
  bool hasGlitch(int droppedFrames) => droppedFrames > 0;
}
