typedef SentenceTtsSpeakCallback = Future<void> Function(
  String text,
  String languageCode,
);
typedef SentenceTtsRateCallback = Future<void> Function(double speed);
typedef AudioPlaybackStateListener = void Function(
  AudioPlaybackSnapshot snapshot,
);

abstract interface class SentenceTtsHook {
  bool get isOfflineReady;

  Future<void> speak(
    String text, {
    String languageCode = 'de-DE',
    double speed = 1.0,
  });

  Future<void> stop();
}

final class CallbackSentenceTtsHook implements SentenceTtsHook {
  const CallbackSentenceTtsHook({
    required this.offlineReady,
    required this.speakCallback,
    this.rateCallback,
    this.stopCallback,
  });

  final bool offlineReady;
  final SentenceTtsSpeakCallback speakCallback;
  final SentenceTtsRateCallback? rateCallback;
  final Future<void> Function()? stopCallback;

  @override
  bool get isOfflineReady => offlineReady;

  @override
  Future<void> speak(
    String text, {
    String languageCode = 'de-DE',
    double speed = 1.0,
  }) async {
    final onRate = rateCallback;
    if (onRate != null) {
      await onRate(speed);
    }
    await speakCallback(text, languageCode);
  }

  @override
  Future<void> stop() async {
    final callback = stopCallback;
    if (callback != null) {
      await callback();
    }
  }
}

enum AudioPlaybackSpeed {
  normal(1.0, '1.0x'),
  slow(0.75, '0.75x');

  const AudioPlaybackSpeed(this.factor, this.label);

  final double factor;
  final String label;
}

enum AudioPlaybackState {
  idle,
  playing,
  stopped,
  unavailable,
  error;

  String get labelAr => switch (this) {
        AudioPlaybackState.idle => 'جاهز',
        AudioPlaybackState.playing => 'يتم التشغيل',
        AudioPlaybackState.stopped => 'متوقف',
        AudioPlaybackState.unavailable => 'الصوت غير متاح',
        AudioPlaybackState.error => 'تعذر تشغيل الصوت',
      };
}

final class AudioPlaybackSnapshot {
  const AudioPlaybackSnapshot({
    required this.state,
    required this.speed,
    this.error,
  });

  final AudioPlaybackState state;
  final AudioPlaybackSpeed speed;
  final Object? error;

  bool get isPlaying => state == AudioPlaybackState.playing;
}

final class AudioPlaybackController {
  AudioPlaybackController({
    required this.hook,
    AudioPlaybackSpeed initialSpeed = AudioPlaybackSpeed.normal,
    AudioPlaybackStateListener? onStateChanged,
  }) : _snapshot = AudioPlaybackSnapshot(
          state: hook.isOfflineReady
              ? AudioPlaybackState.idle
              : AudioPlaybackState.unavailable,
          speed: initialSpeed,
        ) {
    if (onStateChanged != null) {
      _listeners.add(onStateChanged);
    }
  }

  final SentenceTtsHook hook;
  final List<AudioPlaybackStateListener> _listeners =
      <AudioPlaybackStateListener>[];
  AudioPlaybackSnapshot _snapshot;

  AudioPlaybackSnapshot get snapshot => _snapshot;
  AudioPlaybackSpeed get speed => _snapshot.speed;
  AudioPlaybackState get state => _snapshot.state;
  bool get isAvailable => hook.isOfflineReady;

  void addListener(AudioPlaybackStateListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(AudioPlaybackStateListener listener) {
    _listeners.remove(listener);
  }

  void setSpeed(AudioPlaybackSpeed speed) {
    if (_snapshot.speed == speed) return;
    _emit(state: _snapshot.state, speed: speed);
  }

  void toggleSpeed() {
    setSpeed(
      _snapshot.speed == AudioPlaybackSpeed.normal
          ? AudioPlaybackSpeed.slow
          : AudioPlaybackSpeed.normal,
    );
  }

  Future<bool> play(
    String text, {
    String languageCode = 'de-DE',
  }) async {
    if (!hook.isOfflineReady) {
      _emit(
        state: AudioPlaybackState.unavailable,
        speed: _snapshot.speed,
      );
      return false;
    }

    if (_snapshot.isPlaying) {
      await hook.stop();
    }

    _emit(
      state: AudioPlaybackState.playing,
      speed: _snapshot.speed,
    );

    try {
      await hook.speak(
        text,
        languageCode: languageCode,
        speed: _snapshot.speed.factor,
      );
      return true;
    } catch (error) {
      _emit(
        state: AudioPlaybackState.error,
        speed: _snapshot.speed,
        error: error,
      );
      return false;
    }
  }

  Future<void> stop() async {
    if (!hook.isOfflineReady) {
      _emit(
        state: AudioPlaybackState.unavailable,
        speed: _snapshot.speed,
      );
      return;
    }

    try {
      await hook.stop();
      _emit(
        state: AudioPlaybackState.stopped,
        speed: _snapshot.speed,
      );
    } catch (error) {
      _emit(
        state: AudioPlaybackState.error,
        speed: _snapshot.speed,
        error: error,
      );
    }
  }

  void markCompleted() {
    if (!_snapshot.isPlaying) return;
    _emit(
      state: AudioPlaybackState.idle,
      speed: _snapshot.speed,
    );
  }

  void reset() {
    _emit(
      state: hook.isOfflineReady
          ? AudioPlaybackState.idle
          : AudioPlaybackState.unavailable,
      speed: _snapshot.speed,
    );
  }

  void _emit({
    required AudioPlaybackState state,
    required AudioPlaybackSpeed speed,
    Object? error,
  }) {
    _snapshot = AudioPlaybackSnapshot(
      state: state,
      speed: speed,
      error: error,
    );

    for (final listener in List<AudioPlaybackStateListener>.of(_listeners)) {
      listener(_snapshot);
    }
  }
}
