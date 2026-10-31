import 'package:test/test.dart';
import 'package:deutsch_build/src/audio/engine/glottal_waveform_acoustic_engine.dart';

void main() {
  group('GlottalWaveformAcousticEngine Tests', () {
    const engine = GlottalWaveformAcousticEngine();

    test('Initializes with authentic physiological jitter and shimmer targets', () {
      expect(engine.sampleRate, equals(16000));
      expect(engine.targetJitterRatio, inInclusiveRange(0.003, 0.008));
      expect(engine.targetShimmerRatio, inInclusiveRange(0.01, 0.025));
    });

    test('Generates stable LF glottal flow pulses from F0 contour', () {
      final f0Contour = List<double>.filled(10, 130.0); // 10 steps = 100ms at 130Hz
      final excitation = engine.generateGlottalExcitation(f0Contour, seed: 123);

      expect(excitation.length, equals(1600)); // 100ms at 16kHz
      expect(excitation.every((s) => s >= -1.0 && s <= 1.0), isTrue);
      // Verify pulse dynamics: has positive flow and negative derivative closure
      expect(excitation.any((s) => s > 0.3), isTrue);
      expect(excitation.any((s) => s < -0.05), isTrue);
    });
  });
}
