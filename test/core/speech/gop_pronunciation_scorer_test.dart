import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/gop_pronunciation_scorer.dart';

void main() {
  group('GopPronunciationScorer Tests', () {
    const scorer = GopPronunciationScorer();

    test('Assigns excellent grade when acoustic distance is minimal', () {
      final report = scorer.evaluate(
        targetWord: 'Tag',
        expectedPhonemes: ['t', 'aː', 'k'],
        acousticDistances: [0.05, 0.08, 0.06], // Very close to reference
      );

      expect(report.overallScore, greaterThanOrEqualTo(85.0));
      expect(report.isPass, isTrue);
      expect(report.phonemeScores.first.grade, equals(PhonemeGrade.excellent));
    });

    test('Detects mispronounced phoneme and marks it poor', () {
      final report = scorer.evaluate(
        targetWord: 'schön',
        expectedPhonemes: ['ʃ', 'øː', 'n'],
        acousticDistances: [0.05, 1.8, 0.05], // High distance on 'ö' vowel
      );

      final vowelScore = report.phonemeScores[1];
      expect(vowelScore.score, lessThan(50.0));
      expect(vowelScore.grade, equals(PhonemeGrade.poor));
    });
  });
}
