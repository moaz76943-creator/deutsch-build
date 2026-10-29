import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/tonal_contour_recognition_engine.dart';

void main() {
  group('TonalContourRecognitionEngine Tests', () {
    const engine = TonalContourRecognitionEngine();

    test('Classifies sharp falling pitch as fourth tone', () {
      final fallingContour = [220.0, 190.0, 160.0, 120.0]; // Sharp drop
      final result = engine.classifyMandarinTone(
        pitchTrackHz: fallingContour,
        expectedTone: MandarinTone.fourthFalling,
      );

      expect(result.detectedTone, equals(MandarinTone.fourthFalling));
      expect(result.isToneCorrect, isTrue);
    });

    test('Classifies dipping pitch as third tone', () {
      final dippingContour = [180.0, 130.0, 175.0]; // Fall-Rise
      final result = engine.classifyMandarinTone(
        pitchTrackHz: dippingContour,
        expectedTone: MandarinTone.thirdDipping,
      );

      expect(result.detectedTone, equals(MandarinTone.thirdDipping));
      expect(result.isToneCorrect, isTrue);
    });

    test('Provides actionable advice on tone mismatch', () {
      final flatContour = [200.0, 202.0, 201.0, 199.0]; // Flat (Tone 1)
      final result = engine.classifyMandarinTone(
        pitchTrackHz: flatContour,
        expectedTone: MandarinTone.secondRising, // Expected Tone 2
      );

      expect(result.detectedTone, equals(MandarinTone.firstFlatHigh));
      expect(result.isToneCorrect, isFalse);
      expect(result.pedagogicalAdvice, contains('نغمة ثانية'));
    });
  });
}
