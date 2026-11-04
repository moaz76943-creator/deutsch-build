/// Task 1058: Synthetic packet interpolation preventing glitches on packet drops
class OpusPlcSynthesizer {
  int concealedFrames = 0;
  void interpolateLostFrame() => concealedFrames++;
}
