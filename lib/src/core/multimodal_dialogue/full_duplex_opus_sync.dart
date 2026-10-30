/// A continuous 20ms streaming Opus audio packet with sequence and timestamp.
class OpusAudioPacket {
  final int sequenceNumber;
  final int timestampMs;
  final List<int> payloadBytes;
  final bool isSilence;

  const OpusAudioPacket({
    required this.sequenceNumber,
    required this.timestampMs,
    required this.payloadBytes,
    required this.isSilence,
  });
}

/// Manages zero-latency 20ms audio frame chunking, jitter buffering, and packet sequencing.
class FullDuplexOpusSynchronizer {
  final int frameDurationMs;
  int _sequenceCounter = 0;
  final List<OpusAudioPacket> _jitterBuffer = [];

  FullDuplexOpusSynchronizer({this.frameDurationMs = 20});

  int get bufferedPacketCount => _jitterBuffer.length;
  int get currentSequence => _sequenceCounter;

  /// Chunks raw PCM byte stream into synchronized 20ms Opus packets.
  List<OpusAudioPacket> chunkPcmStream(List<int> rawPcmBytes, {int bytesPer20MsFrame = 640}) {
    if (rawPcmBytes.isEmpty) return [];

    final packets = <OpusAudioPacket>[];
    int offset = 0;

    while (offset < rawPcmBytes.length) {
      final end = (offset + bytesPer20MsFrame).clamp(0, rawPcmBytes.length);
      final frameBytes = rawPcmBytes.sublist(offset, end);

      final isAllZeros = frameBytes.every((b) => b == 0);
      final packet = OpusAudioPacket(
        sequenceNumber: _sequenceCounter++,
        timestampMs: _sequenceCounter * frameDurationMs,
        payloadBytes: frameBytes,
        isSilence: isAllZeros,
      );

      packets.add(packet);
      _jitterBuffer.add(packet);
      offset += bytesPer20MsFrame;
    }

    return packets;
  }

  /// Retrieves the next ordered frame from jitter buffer for continuous DAC playback.
  OpusAudioPacket? pullNextFrame() {
    if (_jitterBuffer.isEmpty) return null;
    return _jitterBuffer.removeAt(0);
  }

  /// Clears buffer.
  void flush() {
    _jitterBuffer.clear();
  }
}
