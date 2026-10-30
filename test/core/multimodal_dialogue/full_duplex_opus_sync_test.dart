import 'package:test/test.dart';
import '../../lib/src/core/multimodal_dialogue/full_duplex_opus_sync.dart';

void main() {
  group('FullDuplexOpusSynchronizer Unit Tests (N067)', () {
    test('Chunks PCM stream into ordered 20ms audio packets with incrementing timestamps', () {
      final synchronizer = FullDuplexOpusSynchronizer();
      final pcmBytes = List<int>.generate(1280, (i) => (i % 256)); // Exactly 2 frames of 640 bytes

      final packets = synchronizer.chunkPcmStream(pcmBytes, bytesPer20MsFrame: 640);
      expect(packets.length, equals(2));
      expect(packets[0].sequenceNumber, equals(0));
      expect(packets[0].timestampMs, equals(20));
      expect(packets[1].sequenceNumber, equals(1));
      expect(packets[1].timestampMs, equals(40));
      expect(packets[0].isSilence, isFalse);

      final pulled = synchronizer.pullNextFrame();
      expect(pulled?.sequenceNumber, equals(0));
      expect(synchronizer.bufferedPacketCount, equals(1));
    });

    test('Correctly identifies silence frames', () {
      final synchronizer = FullDuplexOpusSynchronizer();
      final silenceBytes = List<int>.filled(640, 0);

      final packets = synchronizer.chunkPcmStream(silenceBytes, bytesPer20MsFrame: 640);
      expect(packets.first.isSilence, isTrue);
    });

    test('Empty audio yields zero packets', () {
      final synchronizer = FullDuplexOpusSynchronizer();
      expect(synchronizer.chunkPcmStream([]), isEmpty);
      expect(synchronizer.pullNextFrame(), isNull);
    });
  });
}
