import 'dart:math' as math;

/// Extracted multi-word collocation with lexical bonding metrics.
class CollocationCandidate {
  final String phrase;
  final String baseHead;
  final String collocate;
  final double pmiScore; // Pointwise Mutual Information
  final double diceCoefficient;
  final bool isStrongCollocation;

  const CollocationCandidate({
    required this.phrase,
    required this.baseHead,
    required this.collocate,
    required this.pmiScore,
    required this.diceCoefficient,
    required this.isStrongCollocation,
  });
}

/// Extracts idiomatic phrases, verb-preposition bundles, and multi-word expressions.
class CollocationMweExtractor {
  static const Map<String, List<String>> _fixedPrepositionVerbs = {
    'abhängen': ['von', 'dat'],
    'warten': ['auf', 'akk'],
    'freuen': ['auf', 'über', 'akk'],
    'bestehen': ['aus', 'auf', 'in'],
    'denken': ['an', 'akk'],
  };

  /// Calculates Pointwise Mutual Information (PMI) between two tokens in a corpus.
  double calculatePmi({
    required int coOccurrenceCount,
    required int countA,
    required int countB,
    required int totalCorpusTokens,
  }) {
    if (coOccurrenceCount <= 0 || countA <= 0 || countB <= 0 || totalCorpusTokens <= 0) {
      return 0.0;
    }
    final probCo = coOccurrenceCount / totalCorpusTokens;
    final probA = countA / totalCorpusTokens;
    final probB = countB / totalCorpusTokens;
    final pmi = math.log(probCo / (probA * probB)) / math.ln2;
    return pmi;
  }

  /// Calculates Dice coefficient for mutual bonding.
  double calculateDice({
    required int coOccurrenceCount,
    required int countA,
    required int countB,
  }) {
    if (countA + countB == 0) return 0.0;
    return (2.0 * coOccurrenceCount) / (countA + countB);
  }

  /// Evaluates whether a verb and preposition form an essential governed collocate.
  CollocationCandidate evaluateVerbPreposition({
    required String verb,
    required String preposition,
    required int coOccurrences,
    required int verbCount,
    required int prepCount,
    int corpusTokens = 1000000,
  }) {
    final vLower = verb.toLowerCase();
    final pLower = preposition.toLowerCase();
    final isGoverned = _fixedPrepositionVerbs[vLower]?.contains(pLower) ?? false;

    final pmi = calculatePmi(
      coOccurrenceCount: coOccurrences,
      countA: verbCount,
      countB: prepCount,
      totalCorpusTokens: corpusTokens,
    );
    final dice = calculateDice(
      coOccurrenceCount: coOccurrences,
      countA: verbCount,
      countB: prepCount,
    );

    return CollocationCandidate(
      phrase: '$verb $preposition',
      baseHead: vLower,
      collocate: pLower,
      pmiScore: double.parse(pmi.toStringAsFixed(2)),
      diceCoefficient: double.parse(dice.toStringAsFixed(3)),
      isStrongCollocation: isGoverned || pmi > 3.0,
    );
  }
}
