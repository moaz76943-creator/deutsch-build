enum CrossLingualTransferType {
  positiveCognateLoan, // Shared etymology or direct loanword (e.g. Ar: كتاب -> Tr: kitap, Sw: kitabu)
  negativeFalseFriend, // Deceptive surface similarity with distinct meaning
  syntacticIsomorphism, // Identical word order or grammatical construct
  semanticCalque, // Word-for-word metaphorical loan
}

class CrossLingualTransferPair {
  final String sourceLemma;
  final String targetLemma;
  final String sourceLang;
  final String targetLang;
  final CrossLingualTransferType type;
  final String pedagogicalExplanationAr;
  final String exampleUsage;
  final String? warningCaution;

  const CrossLingualTransferPair({
    required this.sourceLemma,
    required this.targetLemma,
    required this.sourceLang,
    required this.targetLang,
    required this.type,
    required this.pedagogicalExplanationAr,
    required this.exampleUsage,
    this.warningCaution,
  });

  bool get isPositiveTransfer => type == CrossLingualTransferType.positiveCognateLoan ||
      type == CrossLingualTransferType.syntacticIsomorphism;
}

/// Sovereign on-device Cross-Lingual Transfer Facilitator.
/// Leverages the learner's known languages to accelerate acquisition via positive transfer
/// while preemptively neutralizing interference from false cognates.
class CrossLingualTransferFacilitator {
  final List<CrossLingualTransferPair> _pairs = [];

  CrossLingualTransferFacilitator();

  int get registeredPairCount => _pairs.length;

  void registerPair(CrossLingualTransferPair pair) {
    _pairs.add(pair);
  }

  /// Scans a target word or sentence and identifies transfer opportunities or hazards.
  List<CrossLingualTransferPair> analyzeTransfer({
    required String targetWord,
    required String targetLang,
    required Set<String> learnerKnownLanguages,
  }) {
    final cleanWord = targetWord.trim().toLowerCase();
    final results = <CrossLingualTransferPair>[];

    for (final pair in _pairs) {
      if (pair.targetLang != targetLang) continue;
      if (!learnerKnownLanguages.contains(pair.sourceLang)) continue;

      if (pair.targetLemma.toLowerCase() == cleanWord) {
        results.add(pair);
      }
    }

    return results;
  }
}
