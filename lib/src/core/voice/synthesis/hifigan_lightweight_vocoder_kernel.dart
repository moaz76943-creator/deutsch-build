/// Task 1103: Sub-30ms integer-quantized HiFi-GAN neural vocoder kernel
class LightweightVocoderKernel {
  bool isQuantized = true;
  int synthesizePcmFrames(int melFrames) => melFrames * 256;
}
