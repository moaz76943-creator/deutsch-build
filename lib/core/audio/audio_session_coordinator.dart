enum AudioPlaybackState { idle, buffering, playing, paused, ducked, stopped }

class AudioSessionCoordinator {
  AudioPlaybackState _state = AudioPlaybackState.idle;
  String? _activeAudioId;

  AudioPlaybackState get state => _state;
  String? get activeAudioId => _activeAudioId;

  bool requestFocus(String audioId) {
    if (_state == AudioPlaybackState.playing && _activeAudioId != audioId) {
      stopCurrent();
    }
    _activeAudioId = audioId;
    _state = AudioPlaybackState.playing;
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
