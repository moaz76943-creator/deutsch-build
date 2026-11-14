import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/audio/engine/formant_spectrogram_renderer.dart';

void main() {
  group('FormantSpectrogramRenderer Tests', () {
    const renderer = FormantSpectrogramRenderer(fftSize: 256, sampleRate: 16000);

    test('Bin resolution and frequency count conform to Nyquist limits', () {
      expect(renderer.binResolutionHz, equals(62.5));
      expect(renderer.frequencyBinCount, equals(128));
    });

    test('Computes valid spectrogram slice with dB values within [-80, 0]', () {
      final window = Float32List(256);
      for (int i = 0; i < 256; i++) {
        // Multi-tone synthetic signal (500Hz and 1500Hz)
        window[i] = (0.5 * math.sin(2.0 * math.pi * 500.0 * i / 16000.0) +
                     0.3 * math.sin(2.0 * math.pi * 1500.0 * i / 16000.0)).clamp(-1.0, 1.0);
      }

      final slice = renderer.computeSlice(window, timestamp: 0.25);
      expect(slice.magnitudeDb.length, equals(128));
      expect(slice.magnitudeDb.every((db) => db >= -80.0 && db <= 0.0), isTrue);
      expect(slice.estimatedF1Hz, inInclusiveRange(400.0, 650.0));
    });
  });
}
