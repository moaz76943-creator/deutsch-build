import 'dart:math';

/// Alignment operation type for token mapping.
enum AlignmentOperation { match, substitution, deletion, insertion }

/// Mapped token pair result from forced alignment.
class AlignedTokenPair {
  final String referenceToken;
  final String spokenToken;
  final AlignmentOperation operation;

  const AlignedTokenPair({
    required this.referenceToken,
    required this.spokenToken,
    required this.operation,
  });
}

/// Comprehensive sentence alignment analysis.
class ForcedAlignmentReport {
  final List<AlignedTokenPair> alignedPairs;
  final int matchingTokensCount;
  final int missingTokensCount; // Deletions
  final double sentenceMatchPercentage;

  const ForcedAlignmentReport({
    required this.alignedPairs,
    required this.matchingTokensCount,
    required this.missingTokensCount,
    required this.sentenceMatchPercentage,
  });
}

/// Aligns recognized words against reference transcript using sequence DTW.
class DtwSpeechTextAligner {
  const DtwSpeechTextAligner();

  /// Computes optimal sequence alignment matrix.
  ForcedAlignmentReport align({
    required List<String> referenceTokens,
    required List<String> spokenTokens,
  }) {
    final n = referenceTokens.length;
    final m = spokenTokens.length;

    final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));

    for (int i = 0; i <= n; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= m; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final cost = (referenceTokens[i - 1].toLowerCase() == spokenTokens[j - 1].toLowerCase()) ? 0 : 1;
        dp[i][j] = min(
          dp[i - 1][j] + 1, // Deletion
          min(dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost), // Insertion or Match/Sub
        );
      }
    }

    // Backtrack to assemble aligned pairs
    int i = n;
    int j = m;
    final List<AlignedTokenPair> pairs = [];
    int matchCount = 0;
    int delCount = 0;

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && referenceTokens[i - 1].toLowerCase() == spokenTokens[j - 1].toLowerCase()) {
        pairs.add(AlignedTokenPair(
          referenceToken: referenceTokens[i - 1],
          spokenToken: spokenTokens[j - 1],
          operation: AlignmentOperation.match,
        ));
        matchCount++;
        i--;
        j--;
      } else if (i > 0 && j > 0 && dp[i][j] == dp[i - 1][j - 1] + 1) {
        pairs.add(AlignedTokenPair(
          referenceToken: referenceTokens[i - 1],
          spokenToken: spokenTokens[j - 1],
          operation: AlignmentOperation.substitution,
        ));
        i--;
        j--;
      } else if (i > 0 && dp[i][j] == dp[i - 1][j] + 1) {
        pairs.add(AlignedTokenPair(
          referenceToken: referenceTokens[i - 1],
          spokenToken: '[MISSED]',
          operation: AlignmentOperation.deletion,
        ));
        delCount++;
        i--;
      } else {
        pairs.add(AlignedTokenPair(
          referenceToken: '[EXTRA]',
          spokenToken: spokenTokens[j - 1],
          operation: AlignmentOperation.insertion,
        ));
        j--;
      }
    }

    final double matchRate = n > 0 ? (matchCount / n * 100.0) : 0.0;

    return ForcedAlignmentReport(
      alignedPairs: pairs.reversed.toList(),
      matchingTokensCount: matchCount,
      missingTokensCount: delCount,
      sentenceMatchPercentage: double.parse(matchRate.toStringAsFixed(1)),
    );
  }
}
