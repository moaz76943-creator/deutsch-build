import 'dart:math' as math;

/// Lexical diversity report for dialogue evaluation.
class DiversityMetrics {
  final double typeTokenRatio; // TTR
  final double movingAverageTtr; // MATTR
  final double repetitionPenalty;
  final bool hasRepetitiveLooping;

  const DiversityMetrics({
    required this.typeTokenRatio,
    required this.movingAverageTtr,
    required this.repetitionPenalty,
    required this.hasRepetitiveLooping,
  });
}

/// Evaluates generated and learner text to enforce lexical diversity and detect robotic repetition.
class SemanticDensityGovernor {
  final int windowSize;
  final double minAcceptableTtr;

  const SemanticDensityGovernor({
    this.windowSize = 20,
    this.minAcceptableTtr = 0.60,
  });

  /// Calculates Moving-Average Type-Token Ratio (MATTR) over a sliding token window.
  DiversityMetrics evaluateDiversity(String text) {
    final tokens = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return const DiversityMetrics(
        typeTokenRatio: 1.0,
        movingAverageTtr: 1.0,
        repetitionPenalty: 0.0,
        hasRepetitiveLooping: false,
      );
    }

    final uniqueCount = tokens.toSet().length;
    final overallTtr = uniqueCount / tokens.length;

    double sumMattr = 0.0;
    int windowCount = 0;

    if (tokens.length <= windowSize) {
      sumMattr = overallTtr;
      windowCount = 1;
    } else {
      for (int i = 0; i <= tokens.length - windowSize; i++) {
        final subTokens = tokens.sublist(i, i + windowSize);
        final subUnique = subTokens.toSet().length;
        sumMattr += (subUnique / windowSize);
        windowCount++;
      }
    }

    final avgMattr = sumMattr / windowCount;
    final isRepetitive = avgMattr < minAcceptableTtr;

    // Repetition penalty escalates as MATTR collapses
    final penalty = isRepetitive ? (1.0 - (avgMattr / minAcceptableTtr)) * 2.0 : 0.0;

    return DiversityMetrics(
      typeTokenRatio: double.parse(overallTtr.toStringAsFixed(3)),
      movingAverageTtr: double.parse(avgMattr.toStringAsFixed(3)),
      repetitionPenalty: double.parse(penalty.toStringAsFixed(3)),
      hasRepetitiveLooping: isRepetitive,
    );
  }
}
