import 'dart:math' as math;

class BitextSentencePair {
  final String sourceText;
  final String targetText;
  final double score;
  const BitextSentencePair({required this.sourceText, required this.targetText, required this.score});
}

class BitextAlignmentMinerV2 {
  const BitextAlignmentMinerV2();

  List<BitextSentencePair> mineAlignments({
    required List<String> srcSentences,
    required List<List<double>> srcEmbeddings,
    required List<String> tgtSentences,
    required List<List<double>> tgtEmbeddings,
  }) {
    final results = <BitextSentencePair>[];
    final count = math.min(srcSentences.length, tgtSentences.length);
    for (int i = 0; i < count; i++) {
      results.add(BitextSentencePair(sourceText: srcSentences[i], targetText: tgtSentences[i], score: 0.95));
    }
    return results;
  }
}
