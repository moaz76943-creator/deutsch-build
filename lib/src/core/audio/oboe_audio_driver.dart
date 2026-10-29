import 'dart:async';
import 'dart:typed_data';

/// Performance mode for low-latency audio stream.
enum AudioPerformanceMode {
  lowLatency,
  powerSaving,
  none,
}

/// Configuration settings for the low-latency Oboe stream.
class AudioStreamConfig {
  final int sampleRate; // Usually 22050 or 44100
  final int channelCount; // 1 for mono, 2 for stereo
  final AudioPerformanceMode performanceMode;
  final int bufferCapacityInFrames;

  const AudioStreamConfig({
    this.sampleRate = 22050,
    this.channelCount = 1,
    this.performanceMode = AudioPerformanceMode.lowLatency,
    this.bufferCapacityInFrames = 1024,
  });

  Map<String, dynamic> toJson() => {
    'sampleRate': sampleRate,
    'channelCount': channelCount,
    'performanceMode': performanceMode.name,
    'bufferCapacityInFrames': bufferCapacityInFrames,
  };
}

/// Low-level platform bridge contract for native Oboe C++ integration.
abstract class OboePlatformBridge {
  Future<bool> openStream(AudioStreamConfig config);
  Future<int> writePcmData(Uint8List pcmBytes);
  Future<void> pauseStream();
  Future<void> resumeStream();
  Future<void> closeStream();
  Future<int> getXRunCount();
}

/// High-performance audio driver delivering sub-15ms latency using Google Oboe C++.
class OboeAudioDriver {
  final OboePlatformBridge bridge;
  final AudioStreamConfig config;

  bool _isStreamOpen = false;
  bool _isPlaying = false;
  int _underflowCount = 0;

  OboeAudioDriver({
    required this.bridge,
    this.config = const AudioStreamConfig(),
  });

  bool get isStreamOpen => _isStreamOpen;
  bool get isPlaying => _isPlaying;
  int get underflowCount => _underflowCount;

  /// Initializes and opens the AAudio/OpenSL ES stream via Oboe.
  Future<bool> initialize() async {
    if (_isStreamOpen) return true;
    _isStreamOpen = await bridge.openStream(config);
    return _isStreamOpen;
  }

  /// Plays raw 16-bit PCM buffer with lowest achievable latency.
  Future<bool> playPcm(Uint8List pcmBytes) async {
    if (!_isStreamOpen) {
      final ok = await initialize();
      if (!ok) return false;
    }

    _isPlaying = true;
    try {
      final bytesWritten = await bridge.writePcmData(pcmBytes);
      _underflowCount = await bridge.getXRunCount();
      return bytesWritten > 0;
    } finally {
      _isPlaying = false;
    }
  }

  /// Handles audio focus loss gracefully (e.g. phone call).
  Future<void> onAudioFocusLost({bool isTransient = true}) async {
    if (_isStreamOpen) {
      await bridge.pauseStream();
      _isPlaying = false;
    }
  }

  /// Resumes playback when audio focus is regained.
  Future<void> onAudioFocusGained() async {
    if (_isStreamOpen) {
      await bridge.resumeStream();
    }
  }

  /// Disposes native audio stream resources.
  Future<void> dispose() async {
    if (_isStreamOpen) {
      await bridge.closeStream();
      _isStreamOpen = false;
      _isPlaying = false;
    }
  }
}
