import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/speech/pronunciation_remediation_fsrs_engine.dart';

void main() {
  group('PronunciationRemediationFsrsEngine Tests', () {
    const engine = PronunciationRemediationFsrsEngine();

    test('Rewards memory stability on excellent pronunciation', () {
      final adj = engine.calculateAdjustment(
        itemId: 'word_001',
        pronunciationScore: 92.0,
        hasMisplacedStress: false,
        hasVowelErrors: false,
      );

      expect(adj.stabilityMultiplier, greaterThan(1.0));
      expect(adj.difficultyDelta, lessThan(0.0));
      expect(adj.recommendedDrill, equals(RemedialDrillType.none));
    });

    test('Reduces stability and prescribes minimal pair drill on severe vowel errors', () {
      final adj = engine.calculateAdjustment(
        itemId: 'word_002',
        pronunciationScore: 45.0,
        hasMisplacedStress: false,
        hasVowelErrors: true, // Failed ö/ü distinction
      );

      expect(adj.stabilityMultiplier, equals(0.65));
      expect(adj.difficultyDelta, greaterThan(0.5));
      expect(adj.recommendedDrill, equals(RemedialDrillType.minimalPairDiscrimination));
    });
  });
}
