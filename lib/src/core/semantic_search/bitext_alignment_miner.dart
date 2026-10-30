/// Word-to-word alignment link between parallel source and target tokens.
class TokenAlignment {
  final int sourceIndex;
  final String sourceToken;
  final int targetIndex;
  final String targetToken;
  final double confidence;

  const TokenAlignment({
    required this.sourceIndex,
    required this.sourceToken,
    required this.targetIndex,
    required this.targetToken,
    required this.confidence,
  });
}

/// Aligns tokens across bilingual sentence pairs for interactive tap-to-translate glosses.
class BitextAlignmentMiner {
  /// Simple offline heuristic alignment using bilingual dictionary lookups.
  List<TokenAlignment> alignSentencePair({
    required List<String> sourceTokens,
    required List<String> targetTokens,
    required Map<String, String> bilingualDictionary,
  }) {
    final alignments = <TokenAlignment>[];

    for (int sIdx = 0; sIdx < sourceTokens.length; sIdx++) {
      final sToken = sourceTokens[sIdx].toLowerCase();
      final expectedTranslation = bilingualDictionary[sToken]?.toLowerCase();

      if (expectedTranslation != null) {
        for (int tIdx = 0; tIdx < targetTokens.length; tIdx++) {
          final tToken = targetTokens[tIdx].toLowerCase();
          if (tToken == expectedTranslation) {
            alignments.add(TokenAlignment(
              sourceIndex: sIdx,
              sourceToken: sourceTokens[sIdx],
              targetIndex: tIdx,
              targetToken: targetTokens[tIdx],
              confidence: 0.95,
            ));
            break;
          }
        }
      }
    }

    return alignments;
  }

  /// Calculates alignment coverage percentage.
  double calculateCoverage(int sourceLength, List<TokenAlignment> alignments) {
    if (sourceLength == 0) return 0.0;
    final alignedSourceIndices = alignments.map((a) => a.sourceIndex).toSet();
    return (alignedSourceIndices.length / sourceLength) * 100.0;
  }
}
