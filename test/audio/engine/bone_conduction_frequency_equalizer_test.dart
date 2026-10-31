import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/audio/engine/bone_conduction_frequency_equalizer.dart';

void main() {
  group('BoneConductionFrequencyEqualizer Tests', () {
    const equalizer = BoneConductionFrequencyEqualizer();

    test('Initializes with clinically safe presence boost and low cut parameters', () {
      expect(equalizer.sampleRate, equals(16000));
      expect(equalizer.presenceBoostDb, inInclusiveRange(3.0, 8.0));
      expect(equalizer.lowCutoffHz, greaterThanOrEqualTo(100.0));
    });

    test('Attenuates low-frequency DC bias and limits peak excursion', () {
      final input = Float32List(160);
      for (int i = 0; i < 160; i++) {
        // Large low-frequency signal with high amplitude
        input[i] = 1.5;
      }
      final equalized = equalizer.equalizeForBoneConduction(input);

      expect(equalized.length, equals(160));
      // DC / sub-bass should decay rapidly towards zero
      expect(equalized.last.abs(), lessThan(equalized.first.abs()));
      // Limiter must strictly keep output within [-1.0, 1.0]
      expect(equalized.every((s) => s >= -1.0 && s <= 1.0), isTrue);
    });
  });
}
