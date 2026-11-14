import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/speech/acoustic_pitch_contour_aligner.dart';

void main() {
  group('AcousticPitchContourAligner Tests', () {
    const aligner = AcousticPitchContourAligner();

    test('Aligns nearly identical pitch contours with high similarity', () {
      final ref = [120.0, 130.0, 145.0, 140.0, 125.0];
      final learner = [122.0, 128.0, 143.0, 141.0, 124.0];

      final result = aligner.alignAndScore(
        learnerPitchContour: learner,
        referencePitchContour: ref,
      );

      expect(result.similarityScore, greaterThanOrEqualTo(85.0));
      expect(result.isIntonationCorrect, isTrue);
    });

    test('Detects inverted pitch contour (rising vs falling intonation)', () {
      final ref = [110.0, 120.0, 140.0, 160.0]; // Rising (Question)
      final learner = [160.0, 140.0, 120.0, 110.0]; // Falling (Statement)

      final result = aligner.alignAndScore(
        learnerPitchContour: learner,
        referencePitchContour: ref,
      );

      expect(result.similarityScore, lessThan(60.0));
      expect(result.isIntonationCorrect, isFalse);
    });
  });
}
