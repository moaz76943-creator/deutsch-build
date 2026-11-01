import 'package:test/test.dart';
import 'package:deutsch_build/src/audio/engine/dynamic_speech_rate_pacer.dart';

void main() {
  group('DynamicSpeechRatePacer Tests', () {
    const pacer = DynamicSpeechRatePacer();

    test('Calculates authentic CEFR syllables-per-second targets', () {
      expect(pacer.getTargetSps(CefrPacingLevel.a1Beginner), equals(2.4));
      expect(pacer.getTargetSps(CefrPacingLevel.b1Intermediate), equals(4.0));
      expect(pacer.getTargetSps(CefrPacingLevel.c1c2Mastery), equals(5.4));
    });

    test('Inserts longer cognitive pauses at punctuation boundaries', () {
      const text = 'Hallo, wie geht es dir? Gut.';
      final pacedUnits = pacer.paceText(text, level: CefrPacingLevel.a1Beginner);

      expect(pacedUnits.length, equals(6));
      // Unit ending with comma must have medium clause pause
      final commaUnit = pacedUnits.firstWhere((u) => u.textToken.contains(','));
      expect(commaUnit.pauseAfterSeconds, greaterThanOrEqualTo(0.3));

      // Unit ending with question mark must have long terminal pause
      final questionUnit = pacedUnits.firstWhere((u) => u.textToken.contains('?'));
      expect(questionUnit.pauseAfterSeconds, greaterThanOrEqualTo(0.6));
    });
  });
}
