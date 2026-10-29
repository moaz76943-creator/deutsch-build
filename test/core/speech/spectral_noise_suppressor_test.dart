import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/spectral_noise_suppressor.dart';

void main() {
  group('SpectralNoiseSuppressor Tests', () {
    const suppressor = SpectralNoiseSuppressor();

    test('Estimates noise floor accurately from silence frame', () {
      final silence = Int16List.fromList([50, -50, 40, -40, 60]);
      final floor = suppressor.estimateNoiseFloor(silence);

      expect(floor, equals(48.0));
    });

    test('Attenuates low-amplitude background noise while preserving loud speech signals', () {
      final noisyAudio = Int16List.fromList([
        30, -30, 40, // Ambient noise
        8000, 12000, // Loud speech vowel
        25, -20      // Ambient noise
      ]);

      final cleaned = suppressor.process(noisyAudio, estimatedNoiseFloor: 50.0);

      // Noise samples should be heavily attenuated
      expect(cleaned[0].abs(), lessThan(5));
      expect(cleaned[1].abs(), lessThan(5));

      // Speech samples should be preserved
      expect(cleaned[3], greaterThan(7000));
      expect(cleaned[4], greaterThan(11000));
    });
  });
}
