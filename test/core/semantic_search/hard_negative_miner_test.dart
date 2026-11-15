import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/hard_negative_miner.dart';

void main() {
  group('HardNegativeMiner Unit Tests (N051)', () {
    final miner = HardNegativeMiner();

    test('Mines semantic near-synonym distractor for wissen vs kennen', () {
      final distractors = miner.mineDistractors('wissen');
      expect(distractors.length, equals(1));
      expect(distractors.first.distractorWord, equals('kennen'));
      expect(distractors.first.type, equals(ConfusionType.semanticNearSynonym));
      expect(distractors.first.contrastiveNote, contains('Ich weiß'));
      expect(miner.calculateDeceptionRating(distractors.first), greaterThan(0.85));
    });

    test('Mines phonetic minimal pair distractor for fördern vs fordern', () {
      final distractors = miner.mineDistractors('fordern');
      expect(distractors.isNotEmpty, isTrue);
      expect(distractors.first.type, equals(ConfusionType.phoneticMinimalPair));
      expect(distractors.first.contrastiveNote, contains('umlaut'));
    });

    test('Returns empty list for words without catalogued distractors', () {
      expect(miner.mineDistractors('apfel'), isEmpty);
    });
  });
}
