class BidirectionalStreamMultiplexer {
  bool isMicActive = true;
  bool isSpeakerActive = true;
  void toggleMute() => isMicActive = !isMicActive;
}
