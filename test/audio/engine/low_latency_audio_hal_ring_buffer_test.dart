import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/audio/engine/low_latency_audio_hal_ring_buffer.dart';

void main() {
  group('LowLatencyAudioHalRingBuffer Tests', () {
    test('Capacity must be a power of two', () {
      expect(() => LowLatencyAudioHalRingBuffer(capacity: 1000), throwsArgumentError);
      final valid = LowLatencyAudioHalRingBuffer(capacity: 1024);
      expect(valid.capacity, equals(1024));
    });

    test('Performs non-blocking writes and reads accurately', () {
      final ring = LowLatencyAudioHalRingBuffer(capacity: 256);
      final input = Float32List.fromList([0.1, 0.2, 0.3, 0.4, 0.5]);

      final written = ring.write(input);
      expect(written, equals(5));
      expect(ring.availableToRead, equals(5));
      expect(ring.availableToWrite, equals(251));

      final output = Float32List(5);
      final readCount = ring.read(output);
      expect(readCount, equals(5));
      expect(output, equals(input));
      expect(ring.availableToRead, equals(0));
    });

    test('Zero-fills on buffer underflow to prevent audio distortion', () {
      final ring = LowLatencyAudioHalRingBuffer(capacity: 128);
      final dest = Float32List(10);
      final read = ring.read(dest);

      expect(read, equals(0));
      expect(ring.underflowCount, equals(1));
      expect(dest.every((s) => s == 0.0), isTrue);
    });
  });
}
