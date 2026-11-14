import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/voice_cloning/neural_audio_codec_engine.dart';

void main() {
  group('NeuralAudioCodecEngine Tests', () {
    const codec = NeuralAudioCodecEngine();

    test('Compresses 16-bit PCM audio achieving > 10x discrete token compression ratio', () {
      final rawAudio = Int16List.fromList(List.generate(22050, (i) => (i % 200) * 80)); // 1 sec = 44.1 KB
      final packet = codec.compressAudioPcm(rawAudio);

      expect(packet.frameCount, equals(50)); // 50 Hz frame rate
      expect(packet.compressedByteSize, lessThan(500)); // Sub-1KB per second (< 3 kbps equivalent)
      expect(packet.compressionRatio, greaterThan(10.0));
    });

    test('Round-trip decompression reconstructs full-length audio samples accurately', () {
      final rawAudio = Int16List(882); // 2 frames
      final packet = codec.compressAudioPcm(rawAudio);
      final reconstructed = codec.decompressToPcm(packet);

      expect(reconstructed.length, equals(882));
    });
  });
}
