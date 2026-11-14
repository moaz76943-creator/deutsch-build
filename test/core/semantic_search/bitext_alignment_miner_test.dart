import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/bitext_alignment_miner.dart';

void main() {
  group('BitextAlignmentMiner Unit Tests (N052)', () {
    final miner = BitextAlignmentMiner();

    test('Aligns German-Arabic parallel sentence tokens accurately', () {
      final german = ['Ich', 'trinke', 'Wasser'];
      final arabic = ['أنا', 'أشرب', 'الماء'];
      final dict = {
        'ich': 'أنا',
        'trinke': 'أشرب',
        'wasser': 'الماء',
      };

      final alignments = miner.alignSentencePair(
        sourceTokens: german,
        targetTokens: arabic,
        bilingualDictionary: dict,
      );

      expect(alignments.length, equals(3));
      expect(alignments[0].sourceToken, equals('Ich'));
      expect(alignments[0].targetToken, equals('أنا'));
      expect(alignments[2].sourceToken, equals('Wasser'));
      expect(alignments[2].targetToken, equals('الماء'));

      final coverage = miner.calculateCoverage(german.length, alignments);
      expect(coverage, equals(100.0));
    });

    test('Handles partial alignment when dictionary has missing entries', () {
      final german = ['Der', 'Hund', 'rennt'];
      final arabic = ['الكلب', 'يركض'];
      final dict = {'hund': 'الكلب', 'rennt': 'يركض'};

      final alignments = miner.alignSentencePair(
        sourceTokens: german,
        targetTokens: arabic,
        bilingualDictionary: dict,
      );

      expect(alignments.length, equals(2));
      final coverage = miner.calculateCoverage(german.length, alignments);
      expect(coverage, closeTo(66.6, 0.5));
    });
  });
}
