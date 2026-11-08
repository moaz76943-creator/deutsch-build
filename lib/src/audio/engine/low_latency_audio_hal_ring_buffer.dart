import 'dart:math' as math;
import 'dart:typed_data';

final class LowLatencyAudioRingBuffer {
  final int capacity;
  final int _mask;
  final Float32List _buffer;
  int _readIndex = 0;
  int _writeIndex = 0;

  factory LowLatencyAudioRingBuffer(int capacity) {
    if (capacity <= 0) {
      throw ArgumentError.value(capacity, 'capacity', 'Buffer capacity must be strictly positive');
    }
    if ((capacity & (capacity - 1)) != 0) {
      throw ArgumentError.value(capacity, 'capacity', 'Buffer capacity must be a power of two');
    }
    return LowLatencyAudioRingBuffer._internal(capacity);
  }

  LowLatencyAudioRingBuffer._internal(this.capacity)
      : _mask = capacity - 1,
        _buffer = Float32List(capacity);

  int get availableRead => _writeIndex - _readIndex;
  int get availableWrite => capacity - availableRead;

  bool write(Float32List samples) {
    if (samples.length > availableWrite) return false;
    for (int i = 0; i < samples.length; i++) {
      _buffer[(_writeIndex + i) & _mask] = samples[i];
    }
    _writeIndex += samples.length;
    return true;
  }

  int read(Float32List destination) {
    final toRead = math.min(destination.length, availableRead);
    for (int i = 0; i < toRead; i++) {
      destination[i] = _buffer[(_readIndex + i) & _mask];
    }
    _readIndex += toRead;
    return toRead;
  }
}
