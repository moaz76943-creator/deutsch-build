import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/audio/engine/autocorrelation_pitch_tracker.dart';

void main() {
  group('AutocorrelationPitchTracker Tests', () {
    const tracker = AutocorrelationPitchTracker();

    test('Initializes with wide 50Hz to 600Hz tracking range', () {
      expect(tracker.sampleRate, equals(16000));
      expect(tracker.minPitchHz, equals(50.0));
      expect(tracker.maxPitchHz, equals(600.0));
    });

    test('Accurately tracks synthetic 150Hz sine wave pitch', () {
      const double targetF0 = 150.0;
      final window = Float32List(640); // 40ms window at 16kHz
      for (int i = 0; i < 640; i++) {
        window[i] = math.sin(2.0 * math.pi * targetF0 * i / 16000.0);
      }

      final result = tracker.estimatePitch(window);
      expect(result.isVoiced, isTrue);
      expect(result.f0Hz, inInclusiveRange(145.0, 155.0)); // Highly accurate!
      expect(result.confidence, greaterThan(0.7));
    });

    test('Detects unvoiced / silent signal correctly', () {
      final silence = Float32List(640);
      final result = tracker.estimatePitch(silence);
      expect(result.isVoiced, isFalse);
      expect(result.f0Hz, equals(0.0));
    });
  });
}
