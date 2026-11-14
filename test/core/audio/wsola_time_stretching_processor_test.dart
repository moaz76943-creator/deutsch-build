import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/core/audio/wsola_time_stretching_processor.dart';

void main() {
  group('WsolaTimeStretchingProcessor Tests', () {
    const processor = WsolaTimeStretchingProcessor();

    Int16List generateSineWave(int samples, double freq, int sampleRate) {
      final list = Int16List(samples);
      for (int i = 0; i < samples; i++) {
        final val = (sin(2 * pi * freq * i / sampleRate) * 16000).round();
        list[i] = val.clamp(-32768, 32767);
      }
      return list;
    }

    test('Passes through audio unchanged when tempo ratio is 1.0', () {
      final input = generateSineWave(44100, 440, 22050); // 2 seconds
      final output = processor.process(input, tempoRatio: 1.0);

      expect(output.length, equals(input.length));
      expect(output[100], equals(input[100]));
    });

    test('Stretches audio duration when tempo ratio is 0.5 (slow motion)', () {
      final input = generateSineWave(22050, 440, 22050); // 1 second
      final output = processor.process(input, tempoRatio: 0.5);

      // Expected output length should be roughly double
      expect(output.length, greaterThan(input.length));
      expect(output.length, greaterThanOrEqualTo(input.length * 1.5));
    });

    test('Compresses audio duration when tempo ratio is 1.5 (speed up)', () {
      final input = generateSineWave(22050, 440, 22050); // 1 second
      final output = processor.process(input, tempoRatio: 1.5);

      expect(output.length, lessThan(input.length));
    });
  });
}
