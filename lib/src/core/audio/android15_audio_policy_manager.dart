import 'dart:async';

/// Android AudioFocus state transitions.
enum AudioFocusState {
  gain,                 // AUDIOFOCUS_GAIN (Full volume)
  lossTransientCanDuck, // AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK (Lower to 20%)
  lossTransient,        // AUDIOFOCUS_LOSS_TRANSIENT (Pause playback)
  loss,                 // AUDIOFOCUS_LOSS (Permanent loss, release resources)
}

/// Foreground service state conforming to Android 15 mediaPlayback requirements.
class ForegroundServiceState {
  final bool isServiceRunning;
  final String activeChannelId;
  final String currentTitle;
  final String currentSpeaker;
  final double volumeDuckingFactor; // 1.0 (normal) to 0.2 (ducked)

  const ForegroundServiceState({
    required this.isServiceRunning,
    required this.activeChannelId,
    required this.currentTitle,
    required this.currentSpeaker,
    this.volumeDuckingFactor = 1.0,
  });

  ForegroundServiceState copyWith({
    bool? isServiceRunning,
    String? activeChannelId,
    String? currentTitle,
    String? currentSpeaker,
    double? volumeDuckingFactor,
  }) {
    return ForegroundServiceState(
      isServiceRunning: isServiceRunning ?? this.isServiceRunning,
      activeChannelId: activeChannelId ?? this.activeChannelId,
      currentTitle: currentTitle ?? this.currentTitle,
      currentSpeaker: currentSpeaker ?? this.currentSpeaker,
      volumeDuckingFactor: volumeDuckingFactor ?? this.volumeDuckingFactor,
    );
  }
}

/// Platform bridge contract for native Android 15 foreground service registration.
abstract class Android15PlatformAudioBridge {
  Future<bool> startMediaPlaybackService({required String channelId, required String title, required String speaker});
  Future<void> stopMediaPlaybackService();
  Future<void> setVolume(double factor);
}

/// Manages Android 15 foreground service constraints and transient audio focus ducking.
class Android15AudioPolicyManager {
  final Android15PlatformAudioBridge bridge;
  final String channelId;

  ForegroundServiceState _state;
  bool _isDisposed = false;

  Android15AudioPolicyManager({
    required this.bridge,
    this.channelId = 'polyglot_audio_playback_channel',
  }) : _state = ForegroundServiceState(
          isServiceRunning: false,
          activeChannelId: channelId,
          currentTitle: 'Idle',
          currentSpeaker: 'None',
        );

  ForegroundServiceState get state => _state;
  bool get isPlayingInBackground => _state.isServiceRunning;

  /// Starts compliant Android 15 mediaPlayback foreground service.
  Future<bool> startPlaybackSession({
    required String wordOrSentence,
    required String speakerName,
  }) async {
    final success = await bridge.startMediaPlaybackService(
      channelId: channelId,
      title: wordOrSentence,
      speaker: speakerName,
    );

    if (success) {
      _state = _state.copyWith(
        isServiceRunning: true,
        currentTitle: wordOrSentence,
        currentSpeaker: speakerName,
        volumeDuckingFactor: 1.0,
      );
    }
    return success;
  }

  /// Handles audio focus events from system.
  Future<void> handleFocusChange(AudioFocusState focusEvent) async {
    switch (focusEvent) {
      case AudioFocusState.gain:
        _state = _state.copyWith(volumeDuckingFactor: 1.0);
        await bridge.setVolume(1.0);
        break;
      case AudioFocusState.lossTransientCanDuck:
        _state = _state.copyWith(volumeDuckingFactor: 0.2); // Duck volume to 20%
        await bridge.setVolume(0.2);
        break;
      case AudioFocusState.lossTransient:
      case AudioFocusState.loss:
        _state = _state.copyWith(volumeDuckingFactor: 0.0);
        await bridge.setVolume(0.0);
        break;
    }
  }

  /// Stops foreground service and cleans up notification.
  Future<void> stopPlaybackSession() async {
    if (_state.isServiceRunning) {
      await bridge.stopMediaPlaybackService();
      _state = _state.copyWith(
        isServiceRunning: false,
        currentTitle: 'Stopped',
        volumeDuckingFactor: 1.0,
      );
    }
  }

  void dispose() {
    _isDisposed = true;
  }
}
