enum AudioQualityTier { compact16k, highFi24k }
class AudioPackDownsamplingQualitySelector {
  static int getSampleRate(AudioQualityTier tier) => tier == AudioQualityTier.compact16k ? 16000 : 24000;
}
