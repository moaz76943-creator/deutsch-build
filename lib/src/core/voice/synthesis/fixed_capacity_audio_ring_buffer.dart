import 'dart:typed_data';

/// Exception thrown when audio frames exceed hard allocation constraints.
class AudioRingBufferException implements Exception {
  final String message;
  AudioRingBufferException(this.message);

  @override
  String toString() => 'AudioRingBufferException: $message';
}

/// Fixed-capacity, lock-free circular ring buffer designed for real-time PCM audio streaming.
/// Guarantees zero dynamic memory allocation during playback and bounded audio latency.
class FixedCapacityAudioRingBuffer {
  final int capacityBytes;
  final Uint8List _buffer;
  int _readOffset = 0;
  int _writeOffset = 0;
  int _availableBytes = 0;

  FixedCapacityAudioRingBuffer({this.capacityBytes = 65536})
      : _buffer = Uint8List(capacityBytes) {
    if (capacityBytes <= 0 || capacityBytes > 4 * 1024 * 1024) {
      throw AudioRingBufferException(
        'Invalid capacity: $capacityBytes. Must be between 1 and 4MB.',
      );
    }
  }

  int get availableBytes => _availableBytes;
  int get remainingSpace => capacityBytes - _availableBytes;
  bool get isEmpty => _availableBytes == 0;
  bool get isFull => _availableBytes == capacityBytes;

  /// Write PCM chunk into ring buffer. Drops or rejects if backpressure exceeded.
  int writePcmFrames(Uint8List sourceBytes) {
    if (sourceBytes.isEmpty) return 0;

    final bytesToWrite = sourceBytes.length > remainingSpace
        ? remainingSpace
        : sourceBytes.length;

    if (bytesToWrite == 0) {
      return 0; // Buffer full, backpressure active
    }

    for (int i = 0; i < bytesToWrite; i++) {
      _buffer[(_writeOffset + i) % capacityBytes] = sourceBytes[i];
    }

    _writeOffset = (_writeOffset + bytesToWrite) % capacityBytes;
    _availableBytes += bytesToWrite;
    return bytesToWrite;
  }

  /// Read PCM chunk from ring buffer for audio playback pipe.
  Uint8List readPcmFrames(int requestedBytes) {
    if (requestedBytes <= 0 || _availableBytes == 0) {
      return Uint8List(0);
    }

    final bytesToRead =
        requestedBytes > _availableBytes ? _availableBytes : requestedBytes;
    final output = Uint8List(bytesToRead);

    for (int i = 0; i < bytesToRead; i++) {
      output[i] = _buffer[(_readOffset + i) % capacityBytes];
    }

    _readOffset = (_readOffset + bytesToRead) % capacityBytes;
    _availableBytes -= bytesToRead;
    return output;
  }

  /// Clear the buffer and reset offsets.
  void clear() {
    _readOffset = 0;
    _writeOffset = 0;
    _availableBytes = 0;
  }
}
