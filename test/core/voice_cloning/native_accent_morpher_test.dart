import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/voice_cloning/native_accent_morpher.dart';

void main() {
  group('NativeAccentMorpher Tests', () {
    const morpher = NativeAccentMorpher();

    test('Morphs audio samples smoothly without clipping boundaries', () {
      final input = Int16List.fromList([1000, 2000, 3000, -2000, -1000]);
      final output = morpher.morphAccent(inputAudio: input);

      expect(output.length, equals(input.length));
      for (final sample in output) {
        expect(sample, greaterThanOrEqualTo(-32768));
        expect(sample, lessThanOrEqualTo(32767));
      }
    });

    test('Calculates precise formant correction shift for German vowel "ü"', () {
      // Learner incorrectly pronouncing "u" (F1 ~ 300, F2 ~ 870) instead of "ü" (F2 ~ 2100)
      final shift = morpher.computeFormantCorrection(
        currentF1: 300.0,
        currentF2: 870.0,
        targetVowel: 'ü',
      );

      expect(shift['targetF2'], equals(2100.0));
      expect(shift['correctionDeltaF2'], greaterThan(1000.0)); // Substantial forward tongue shift
    });
  });
}
