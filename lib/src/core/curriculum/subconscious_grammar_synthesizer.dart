/// Structural variation template for inductive subconscious grammar learning.
class InductiveGrammarPattern {
  final String patternId;
  final String targetFeature;
  final List<String> subjects;
  final String verbBase;
  final List<String> objectsWithArticle;

  const InductiveGrammarPattern({
    required this.patternId,
    required this.targetFeature,
    required this.subjects,
    required this.verbBase,
    required this.objectsWithArticle,
  });
}

/// Synthesizes contextual micro-scaffolds that isolate a single grammatical rule inductively.
class SubconsciousGrammarSynthesizer {
  /// Generates variation sentences that reinforce the rule without metalinguistic explanations.
  List<String> synthesizePatternDrill(InductiveGrammarPattern pattern) {
    final sentences = <String>[];

    for (final subj in pattern.subjects) {
      for (final obj in pattern.objectsWithArticle) {
        sentences.add('$subj ${pattern.verbBase} $obj.');
      }
    }

    return sentences;
  }

  /// Calculates the structural invariance index.
  double evaluatePatternIsolation({
    required List<String> generatedSentences,
    required String invariantVerb,
  }) {
    if (generatedSentences.isEmpty) return 0.0;
    int matches = 0;
    for (final s in generatedSentences) {
      if (s.contains(invariantVerb)) {
        matches++;
      }
    }
    return (matches / generatedSentences.length) * 100.0;
  }
}
