import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/phonetic_contrast_discrimination_engine.dart';

void main() {
  group('PhoneticContrastDiscriminationEngine Tests', () {
    const engine = PhoneticContrastDiscriminationEngine();

    test('Identifies accurate voiceless P with long VOT', () {
      final result = engine.evaluatePlosiveContrast(targetPhoneme: 'p', measuredVotMs: 45.0);

      expect(result.isAccuratelyDiscriminated, isTrue);
      expect(result.correctiveAdvice, contains('رائع'));
    });

    test('Diagnoses P pronounced as B due to short VOT', () {
      final result = engine.evaluatePlosiveContrast(targetPhoneme: 'p', measuredVotMs: 15.0); // Too short, sounds like B

      expect(result.isAccuratelyDiscriminated, isFalse);
      expect(result.confusedPhoneme, equals('b'));
      expect(result.correctiveAdvice, contains('نطقت حرف (P) كأنه (B)'));
    });
  });
}
