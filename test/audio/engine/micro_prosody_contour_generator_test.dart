import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/audio/engine/micro_prosody_contour_generator.dart';

void main() {
  group('MicroProsodyContourGenerator Tests', () {
    const generator = MicroProsodyContourGenerator(baselineF0Hz: 125.0);

    test('Generates smooth F0 trajectory adhering to physiologic limits', () {
      final commands = [
        const PitchCommandEvent(timeSeconds: 0.2, amplitudeHz: 35.0, type: PitchCommandType.emphasisPeak),
        const PitchCommandEvent(timeSeconds: 0.7, amplitudeHz: 40.0, type: PitchCommandType.interrogativeRise),
      ];

      final contour = generator.generateContour(totalDurationSeconds: 1.0, commands: commands);
      expect(contour.length, equals(100)); // 1.0s at 100Hz = 100 points
      expect(contour.every((f0) => f0 >= 60.0 && f0 <= 450.0), isTrue);
      // Peak command at 0.2s should raise F0 above baseline
      expect(contour[35], greaterThan(generator.baselineF0Hz));
    });

    test('Correctly models dipping tone contours', () {
      final commands = [
        const PitchCommandEvent(timeSeconds: 0.1, amplitudeHz: 40.0, type: PitchCommandType.tonalContourDipping),
      ];

      final contour = generator.generateContour(totalDurationSeconds: 0.6, commands: commands);
      expect(contour.length, equals(60));
      expect(contour[15], lessThan(generator.baselineF0Hz)); // Initial dip
    });
  });
}
