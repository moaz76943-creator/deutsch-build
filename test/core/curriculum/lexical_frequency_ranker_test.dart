import 'package:test/test.dart';
import '../../lib/src/core/curriculum/lexical_frequency_ranker.dart';

void main() {
  group('LexicalFrequencyRanker Unit Tests (N022)', () {
    test('Calculates decreasing Zipf score with increasing rank', () {
      final topWordZipf = LexicalFrequencyRanker.calculateZipf(1);
      final midWordZipf = LexicalFrequencyRanker.calculateZipf(1000);
      final rareWordZipf = LexicalFrequencyRanker.calculateZipf(100000);

      expect(topWordZipf, greaterThan(midWordZipf));
      expect(midWordZipf, greaterThan(rareWordZipf));
      expect(topWordZipf, inInclusiveRange(1.0, 7.0));
    });

    test('Maps ranks correctly to standard CEFR bands', () {
      expect(LexicalFrequencyRanker.mapRankToCefr(250), equals('A1'));
      expect(LexicalFrequencyRanker.mapRankToCefr(1200), equals('A2'));
      expect(LexicalFrequencyRanker.mapRankToCefr(2500), equals('B1'));
      expect(LexicalFrequencyRanker.mapRankToCefr(4500), equals('B2'));
      expect(LexicalFrequencyRanker.mapRankToCefr(7500), equals('C1'));
      expect(LexicalFrequencyRanker.mapRankToCefr(15000), equals('C2'));
    });

    test('Ranks candidates in descending order of priority', () {
      final ranker = LexicalFrequencyRanker();
      final candidates = [
        const MapEntry('verfassungsmäßig', 8500),
        const MapEntry('wasser', 120),
        const MapEntry('arbeiten', 450),
      ];

      final result = ranker.rankCandidateWords(candidates);
      expect(result.first.lemma, equals('wasser'));
      expect(result.first.cefrTier, equals('A1'));
      expect(result.last.lemma, equals('verfassungsmäßig'));
      expect(result.last.cefrTier, equals('C1'));
    });
  });
}
