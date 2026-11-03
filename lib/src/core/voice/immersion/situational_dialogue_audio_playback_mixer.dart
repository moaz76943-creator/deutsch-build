/// Task 1191: Real-time audio mixer blending TTS vocal streams with background ambiance
class SituationalAudioMixer {
  double speechGain = 1.0;
  double bgGain = 0.12;
  void duckAmbiance(bool isSpeechActive) => bgGain = isSpeechActive ? 0.05 : 0.15;
}
