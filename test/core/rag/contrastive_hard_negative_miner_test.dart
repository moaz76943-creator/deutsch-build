import 'package:test/test.dart';
import 'package:deutsch_build/src/core/rag/contrastive_hard_negative_miner.dart';

void main() {
  group('ContrastiveHardNegativeMiner Suite', () {
    const miner = ContrastiveHardNegativeMiner(minLexicalOverlapThreshold: 0.4);

    test('Identifies negation inversion as hard negative despite high lexical overlap', () {
      final anchor = CandidateCorpusItem(
        id: 'anc',
        text: 'ذهب الطالب إلى المكتبة صباح اليوم',
        vector: [1.0, 0.0, 0.0, 0.0],
        isNegated: false,
      );

      final positive = CandidateCorpusItem(
        id: 'pos',
        text: 'انطلق التلميذ نحو دار الكتب باكراً',
        vector: [0.95, 0.1, 0.0, 0.0],
        isNegated: false,
      );

      final hardNegative = CandidateCorpusItem(
        id: 'neg_polarity',
        text: 'لم يذهب الطالب إلى المكتبة صباح اليوم',
        vector: [0.65, 0.3, 0.0, 0.0], // Deceptively close in embedding space
        isNegated: true,
      );

      final easyNegative = CandidateCorpusItem(
        id: 'neg_easy',
        text: 'الطقس ماطر وجميل في الجبال',
        vector: [0.0, 0.0, 1.0, 0.0],
        isNegated: false,
      );

      final triplets = miner.mineTriplets(
        anchor: anchor,
        positive: positive,
        candidatePool: [hardNegative, easyNegative],
      );

      expect(triplets, isNotEmpty);
      expect(triplets.first.hardNegativeText, equals(hardNegative.text));
      expect(triplets.first.distractorType, equals(TripletDistractorType.polarityNegation));
      expect(triplets.first.margin, greaterThan(0.0));
    });
  });
}
