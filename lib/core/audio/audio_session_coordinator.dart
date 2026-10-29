enum AudioPlaybackState {
  idle,
  buffering,
  playing,
  paused,
  ducked,
  stopped,
}

/// Lightweight process audio-focus state.
///
/// Existing constructors and methods remain available. [shared] is the common
/// authority for TTS-facing code so parallel facades cannot claim focus
/// independently.
class AudioSessionCoordinator {
  static final AudioSessionCoordinator shared = AudioSessionCoordinator();

  AudioPlaybackState _state = AudioPlaybackState.idle;
  String? _activeAudioId;

  AudioPlaybackState get state => _state;
  String? get activeAudioId => _activeAudioId;

  bool requestFocus(String audioId) {
    if (audioId.trim().isEmpty) return false;
    if (_activeAudioId != null && _activeAudioId != audioId) {
      stopCurrent();
    }
    _activeAudioId = audioId;
    _state = AudioPlaybackState.playing;
    return true;
  }

  /// Releases focus only if the caller still owns the active session.
  bool releaseFocus(String audioId) {
    if (_activeAudioId != audioId) return false;
    stopCurrent();
    return true;
  }

  void duck() {
    if (_state == AudioPlaybackState.playing) {
      _state = AudioPlaybackState.ducked;
    }
  }

  void restoreVolume() {
    if (_state == AudioPlaybackState.ducked) {
      _state = AudioPlaybackState.playing;
    }
  }

  void stopCurrent() {
    _state = AudioPlaybackState.stopped;
    _activeAudioId = null;
  }
}
