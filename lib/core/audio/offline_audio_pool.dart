import 'dart:async';

abstract class AudioPlayerInstance {
  Future<void> play(String assetPath);
  Future<void> stop();
  Future<void> dispose();
  bool get isPlaying;
}

class MockAudioPlayerInstance implements AudioPlayerInstance {
  bool _isPlaying = false;
  bool _isDisposed = false;

  @override
  bool get isPlaying => _isPlaying;
  bool get isDisposed => _isDisposed;

  @override
  Future<void> play(String assetPath) async {
    if (_isDisposed) throw StateError('Cannot play on disposed player');
    _isPlaying = true;
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
  }

  @override
  Future<void> dispose() async {
    _isPlaying = false;
    _isDisposed = true;
  }
}

class OfflineAudioPlugPool {
  final int maxPoolSize;
  final List<AudioPlayerInstance> _availablePool = [];
  final Set<AudioPlayerInstance> _activePool = {};
  bool _isDisposed = false;

  OfflineAudioPlugPool({this.maxPoolSize = 3});

  int get availableCount => _availablePool.length;
  int get activeCount => _activePool.length;

  Future<AudioPlayerInstance> acquirePlayer() async {
    if (_isDisposed) throw StateError('Pool disposed');
    if (_availablePool.isNotEmpty) {
      final player = _availablePool.removeLast();
      _activePool.add(player);
      return player;
    }
    if (_activePool.length < maxPoolSize) {
      final player = MockAudioPlayerInstance();
      _activePool.add(player);
      return player;
    }
    throw StateError('Audio pool exhausted: max capacity reached');
  }

  Future<void> releasePlayer(AudioPlayerInstance player) async {
    if (!_activePool.contains(player)) return;
    await player.stop();
    _activePool.remove(player);
    if (!_isDisposed) {
      _availablePool.add(player);
    } else {
      await player.dispose();
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    for (final p in _activePool) {
      await p.dispose();
    }
    _activePool.clear();
    for (final p in _availablePool) {
      await p.dispose();
    }
    _availablePool.clear();
  }
}
