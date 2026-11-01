import 'dart:math' as math;

enum TripletDistractorType {
  polarityNegation, // e.g. "I went" vs "I did not go"
  grammaticalTenseShift, // e.g. "I will read" vs "I read yesterday"
  subjectObjectInversion, // e.g. "Zaid helped Amr" vs "Amr helped Zaid"
  lexicalDistractor, // High token overlap but completely different meaning
}

class ContrastiveTriplet {
  final String anchorText;
  final List<double> anchorVector;
  final String positiveText;
  final List<double> positiveVector;
  final String hardNegativeText;
  final List<double> hardNegativeVector;
  final TripletDistractorType distractorType;
  final double positiveSimilarity;
  final double negativeSimilarity;

  const ContrastiveTriplet({
    required this.anchorText,
    required this.anchorVector,
    required this.positiveText,
    required this.positiveVector,
    required this.hardNegativeText,
    required this.hardNegativeVector,
    required this.distractorType,
    required this.positiveSimilarity,
    required this.negativeSimilarity,
  });

  /// Margin between positive and hard negative: Sim(A, P) - Sim(A, N)
  double get margin => positiveSimilarity - negativeSimilarity;
}

class CandidateCorpusItem {
  final String id;
  final String text;
  final List<double> vector;
  final Set<String> tokens;
  final bool isNegated;

  CandidateCorpusItem({
    required this.id,
    required this.text,
    required this.vector,
    required this.isNegated,
  }) : tokens = _tokenize(text);

  static Set<String> _tokenize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toSet();
  }
}

/// Sovereign on-device contrastive hard-negative miner.
/// Filters and isolates challenging negative vectors having deceptively high lexical
/// or structural overlap but divergent semantic intent.
class ContrastiveHardNegativeMiner {
  final double minLexicalOverlapThreshold;
  final double targetMargin;

  const ContrastiveHardNegativeMiner({
    this.minLexicalOverlapThreshold = 0.4,
    this.targetMargin = 0.2,
  });

  static double _cosineSim(List<double> v1, List<double> v2) {
    if (v1.length != v2.length || v1.isEmpty) return 0.0;
    double dot = 0.0, n1 = 0.0, n2 = 0.0;
    for (int i = 0; i < v1.length; i++) {
      dot += v1[i] * v2[i];
      n1 += v1[i] * v1[i];
      n2 += v2[i] * v2[i];
    }
    if (n1 == 0.0 || n2 == 0.0) return 0.0;
    return (dot / (math.sqrt(n1) * math.sqrt(n2))).clamp(-1.0, 1.0);
  }

  static double _jaccardSimilarity(Set<String> s1, Set<String> s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    final intersection = s1.intersection(s2).length;
    final union = s1.union(s2).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  /// Mines hard negatives for a given anchor from a pool of candidates.
  List<ContrastiveTriplet> mineTriplets({
    required CandidateCorpusItem anchor,
    required CandidateCorpusItem positive,
    required List<CandidateCorpusItem> candidatePool,
  }) {
    final posSim = _cosineSim(anchor.vector, positive.vector);
    final triplets = <ContrastiveTriplet>[];

    for (final candidate in candidatePool) {
      if (candidate.id == anchor.id || candidate.id == positive.id) continue;

      final lexicalOverlap = _jaccardSimilarity(anchor.tokens, candidate.tokens);
      final negSim = _cosineSim(anchor.vector, candidate.vector);

      // Determine distractor criteria
      bool isHardNegative = false;
      TripletDistractorType distType = TripletDistractorType.lexicalDistractor;

      if (anchor.isNegated != candidate.isNegated && lexicalOverlap >= 0.5) {
        isHardNegative = true;
        distType = TripletDistractorType.polarityNegation;
      } else if (lexicalOverlap >= minLexicalOverlapThreshold && negSim > 0.4) {
        isHardNegative = true;
        distType = TripletDistractorType.lexicalDistractor;
      }

      if (isHardNegative) {
        triplets.add(ContrastiveTriplet(
          anchorText: anchor.text,
          anchorVector: anchor.vector,
          positiveText: positive.text,
          positiveVector: positive.vector,
          hardNegativeText: candidate.text,
          hardNegativeVector: candidate.vector,
          distractorType: distType,
          positiveSimilarity: posSim,
          negativeSimilarity: negSim,
        ));
      }
    }

    // Sort by difficulty: highest negative similarity (hardest negatives first)
    triplets.sort((a, b) => b.negativeSimilarity.compareTo(a.negativeSimilarity));
    return triplets;
  }
}
