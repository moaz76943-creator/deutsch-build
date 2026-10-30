import 'package:test/test.dart';
import 'package:deutsch_build/src/core/voice_cloning/nasal_oral_resonance_detector.dart';

void main() {
  group('NasalOralResonanceDetector Tests', () {
    const detector = NasalOralResonanceDetector();

    test('Validates German nasal consonant "m" with dominant nasal resonance', () {
      final report = detector.evaluateResonance(
        targetPhoneme: 'm',
        lowFreqNasalMurmurDbfs: 65.0,
        midFreqOralFormantDbfs: 35.0,
      );

      expect(report.isVelumPositionCorrect, isTrue);
      expect(report.nasalEnergyRatio, greaterThanOrEqualTo(0.5));
      expect(report.articulatoryFeedback, contains('Perfekter nasaler Luftstrom'));
    });

    test('Flags hypernasality in German pure oral vowel "a:" with velum lift advice', () {
      final report = detector.evaluateResonance(
        targetPhoneme: 'a:',
        lowFreqNasalMurmurDbfs: 55.0, // Erroneously high nasal murmur
        midFreqOralFormantDbfs: 40.0,
      );

      expect(report.isVelumPositionCorrect, isFalse);
      expect(report.articulatoryFeedback, contains('Zu starkes Näseln'));
    });
  });
}
