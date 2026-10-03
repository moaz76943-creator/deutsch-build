import 'dart:async';

enum AudioServiceState { idle, playing, paused, error }

enum AudioServiceFailureCode {
  invalidRequest,
  playbackFailed,
  pauseFailed,
  stopFailed,
  disposed,
}

final class AudioServiceFailure implements Exception {
  const AudioServiceFailure(this.code);

  final AudioServiceFailureCode code;

  @override
  String toString() => 'AudioServiceFailure($code)';
}

abstract interface class GermanAudioEngine {
  Future<void> speakGerman(String text, {required double rate});
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}

abstract interface class AudioService {
  AudioServiceState get state;
  Stream<AudioServiceState> get states;

  Future<void> speakGerman(String text, {double rate = .46});
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}

final class ManagedAudioService implements AudioService {
  ManagedAudioService(this._engine);

  final GermanAudioEngine _engine;
  final StreamController<AudioServiceState> _states =
      StreamController<AudioServiceState>.broadcast();

  AudioServiceState _state = AudioServiceState.idle;
  int _generation = 0;
  bool _disposed = false;

  @override
  AudioServiceState get state => _state;

  @override
  Stream<AudioServiceState> get states => _states.stream;

  @override
  Future<void> speakGerman(String text, {double rate = .46}) async {
    _ensureActive();
    final normalized = text.trim();
    if (normalized.isEmpty || rate < .1 || rate > 1.0) {
      throw const AudioServiceFailure(AudioServiceFailureCode.invalidRequest);
    }

    final generation = ++_generation;
    _emit(AudioServiceState.playing);
    try {
      await _engine.speakGerman(normalized, rate: rate);
      if (!_disposed &&
          generation == _generation &&
          _state == AudioServiceState.playing) {
        _emit(AudioServiceState.idle);
      }
    } on AudioServiceFailure {
      rethrow;
    } on Object {
      if (!_disposed && generation == _generation) {
        _emit(AudioServiceState.error);
      }
      throw const AudioServiceFailure(
        AudioServiceFailureCode.playbackFailed,
      );
    }
  }

  @override
  Future<void> pause() async {
    _ensureActive();
    if (_state != AudioServiceState.playing) return;
    ++_generation;
    try {
      await _engine.pause();
      _emit(AudioServiceState.paused);
    } on Object {
      _emit(AudioServiceState.error);
      throw const AudioServiceFailure(AudioServiceFailureCode.pauseFailed);
    }
  }

  @override
  Future<void> stop() async {
    _ensureActive();
    ++_generation;
    try {
      await _engine.stop();
      _emit(AudioServiceState.idle);
    } on Object {
      _emit(AudioServiceState.error);
      throw const AudioServiceFailure(AudioServiceFailureCode.stopFailed);
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    ++_generation;
    try {
      await _engine.dispose();
    } finally {
      await _states.close();
    }
  }

  void _emit(AudioServiceState next) {
    if (_disposed || _states.isClosed) return;
    _state = next;
    _states.add(next);
  }

  void _ensureActive() {
    if (_disposed) {
      throw const AudioServiceFailure(AudioServiceFailureCode.disposed);
    }
  }
}
