/// Krashen comprehensible input density evaluation report.
class KrashenDensityReport {
  final int totalTokens;
  final int knownTokensCount;
  final int unknownTokensCount;
  final double comprehensionRatio;
  final List<String> targetNovelTokens;
  final bool isOptimalZone;
  final String scaffoldingAdvice;

  const KrashenDensityReport({
    required this.totalTokens,
    required this.knownTokensCount,
    required this.unknownTokensCount,
    required this.comprehensionRatio,
    required this.targetNovelTokens,
    required this.isOptimalZone,
    required this.scaffoldingAdvice,
  });
}

/// Evaluates texts against a learner's lexical vault to maintain the golden 95% known / 5% unknown (i+1) ratio.
class KrashenDensityCalibrator {
  final double minOptimalRatio;
  final double maxOptimalRatio;

  const KrashenDensityCalibrator({
    this.minOptimalRatio = 0.92,
    this.maxOptimalRatio = 0.97,
  });

  /// Analyzes a tokenized passage against the learner's mastered vocabulary.
  KrashenDensityReport calibrate({
    required List<String> passageTokens,
    required Set<String> knownVocabulary,
  }) {
    if (passageTokens.isEmpty) {
      return const KrashenDensityReport(
        totalTokens: 0,
        knownTokensCount: 0,
        unknownTokensCount: 0,
        comprehensionRatio: 1.0,
        targetNovelTokens: [],
        isOptimalZone: false,
        scaffoldingAdvice: 'Passage is empty.',
      );
    }

    final normalizedTokens = passageTokens
        .map((t) => t.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ''))
        .where((t) => t.isNotEmpty)
        .toList();

    int knownCount = 0;
    final novelTokens = <String>{};

    for (final token in normalizedTokens) {
      if (knownVocabulary.contains(token)) {
        knownCount++;
      } else {
        novelTokens.add(token);
      }
    }

    final total = normalizedTokens.length;
    final ratio = total > 0 ? (knownCount / total) : 1.0;
    final isOptimal = ratio >= minOptimalRatio && ratio <= maxOptimalRatio;

    String advice;
    if (ratio > maxOptimalRatio) {
      advice = 'Under-challenging (i+0): Increase lexical density or introduce advanced syntactic forms.';
    } else if (ratio < minOptimalRatio) {
      advice = 'Overwhelming (i+N): Cognitive overload risk. Introduce glossing or simplify context scaffolding.';
    } else {
      advice = 'Optimal Krashen Zone (i+1): Ideal balance for subconscious acquisition.';
    }

    return KrashenDensityReport(
      totalTokens: total,
      knownTokensCount: knownCount,
      unknownTokensCount: total - knownCount,
      comprehensionRatio: ratio,
      targetNovelTokens: novelTokens.toList()..sort(),
      isOptimalZone: isOptimal,
      scaffoldingAdvice: advice,
    );
  }
}
