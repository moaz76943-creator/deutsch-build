import 'dart:typed_data';

/// Encapsulated 20ms voice audio frame packet for mesh peer transmission.
class VoiceFramePacket {
  final int sequenceNumber;
  final int timestampMs;
  final Uint8List payload;

  VoiceFramePacket({
    required this.sequenceNumber,
    required this.timestampMs,
    required this.payload,
  });
}

/// Jitter buffer reordering packets and concealing dropped voice frames (PLC).
class VoiceJitterBuffer {
  final int maxBufferFrames;
  final Map<int, VoiceFramePacket> _packetStore = <int, VoiceFramePacket>{};
  int _expectedSequence = 0;
  int _concealedFrameCount = 0;

  VoiceJitterBuffer({this.maxBufferFrames = 8});

  int get queuedFrameCount => _packetStore.length;
  int get concealedCount => _concealedFrameCount;

  /// Insert an incoming network packet into the jitter buffer.
  void pushPacket(VoiceFramePacket packet) {
    if (packet.sequenceNumber >= _expectedSequence) {
      _packetStore[packet.sequenceNumber] = packet;

      // Bound buffer size: purge oldest if overflow
      if (_packetStore.length > maxBufferFrames) {
        final lowestSeq = _packetStore.keys.reduce((a, b) => a < b ? a : b);
        _packetStore.remove(lowestSeq);
      }
    }
  }

  /// Pull the next ordered frame for playback. Performs PLC if packet was dropped.
  Uint8List pullNextOrderedFrame({int defaultFrameBytes = 320}) {
    if (_packetStore.containsKey(_expectedSequence)) {
      final packet = _packetStore.remove(_expectedSequence)!;
      _expectedSequence++;
      return packet.payload;
    }

    // Packet Loss Concealment (PLC): emit silent frame to prevent audio clock desync
    _expectedSequence++;
    _concealedFrameCount++;
    return Uint8List(defaultFrameBytes);
  }

  void reset(int startSequence) {
    _packetStore.clear();
    _expectedSequence = startSequence;
    _concealedFrameCount = 0;
  }
}
