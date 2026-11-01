import 'dart:typed_data';

class ZeroCopyAudioRingBuffer {
  final int capacityBytes;
  final Uint8List _storage;
  int _writePos = 0;
  int _readPos = 0;

  ZeroCopyAudioRingBuffer({this.capacityBytes = 8192}) : _storage = Uint8List(capacityBytes);

  void writeChunk(Uint8List chunk) {
    for (int i = 0; i < chunk.length; i++) {
      _storage[_writePos] = chunk[i];
      _writePos = (_writePos + 1) % capacityBytes;
    }
  }

  Uint8List readChunk(int size) {
    final out = Uint8List(size);
    for (int i = 0; i < size; i++) {
      out[i] = _storage[_readPos];
      _readPos = (_readPos + 1) % capacityBytes;
    }
    return out;
  }
}
