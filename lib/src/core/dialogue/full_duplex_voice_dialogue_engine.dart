enum VoiceChannelState {
  idle,
  listeningToLearner,
  learnerSilenceDetected,
  tutorSpeaking,
  bargeInInterrupted,
}

class AudioStreamFrame {
  final List<int> pcmSamples;
  final double rmsEnergy;
  final bool isSpeechActive;

  const AudioStreamFrame({
    required this.pcmSamples,
    required this.rmsEnergy,
    required this.isSpeechActive,
  });
}

class FullDuplexVoiceDialogueEngine {
  final double speechEnergyThreshold;
  final int silenceTimeoutMs;
  VoiceChannelState currentState;
  int _consecutiveSilenceFrames = 0;
  bool _playbackInterrupted = false;

  FullDuplexVoiceDialogueEngine({
    this.speechEnergyThreshold = 0.08,
    this.silenceTimeoutMs = 700,
    this.currentState = VoiceChannelState.idle,
  });

  bool get isPlaybackInterrupted => _playbackInterrupted;

  /// Processes continuous inbound mic audio frame during full-duplex session.
  VoiceChannelState processInboundAudioFrame(AudioStreamFrame frame) {
    if (frame.isSpeechActive && frame.rmsEnergy >= speechEnergyThreshold) {
      _consecutiveSilenceFrames = 0;

      // If tutor was speaking and learner starts talking, trigger instant barge-in cutoff
      if (currentState == VoiceChannelState.tutorSpeaking) {
        currentState = VoiceChannelState.bargeInInterrupted;
        _playbackInterrupted = true;
        return currentState;
      }

      currentState = VoiceChannelState.listeningToLearner;
      _playbackInterrupted = false;
      return currentState;
    } else {
      // Silence or background ambient noise
      if (currentState == VoiceChannelState.listeningToLearner) {
        _consecutiveSilenceFrames++;
        final int elapsedSilenceMs = _consecutiveSilenceFrames * 50; // 50ms per frame

        if (elapsedSilenceMs >= silenceTimeoutMs) {
          currentState = VoiceChannelState.learnerSilenceDetected;
          _consecutiveSilenceFrames = 0;
          return currentState;
        }
      }
      return currentState;
    }
  }

  /// Sets state when tutor begins audio synthesis playback.
  void notifyTutorSpeakingStarted() {
    currentState = VoiceChannelState.tutorSpeaking;
    _playbackInterrupted = false;
    _consecutiveSilenceFrames = 0;
  }

  /// Resets audio pipeline for next conversational turn.
  void resetTurn() {
    currentState = VoiceChannelState.idle;
    _playbackInterrupted = false;
    _consecutiveSilenceFrames = 0;
  }
}
