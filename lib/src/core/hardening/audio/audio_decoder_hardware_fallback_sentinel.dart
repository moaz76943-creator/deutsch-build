/// Task 1051: Hardware accelerated AAC/Opus decoder fallback to software
class AudioDecoderFallbackSentinel {
  bool isHardwareActive = true;
  void fallbackToSoftware() => isHardwareActive = false;
  String get activeDecoder => isHardwareActive ? 'HARDWARE' : 'SOFTWARE';
}
