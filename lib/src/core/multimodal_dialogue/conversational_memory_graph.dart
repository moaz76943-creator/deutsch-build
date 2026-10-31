/// A persistent learned personal fact about the learner.
class LearnerFact {
  final String category; // e.g. 'hobby', 'profession', 'pet', 'travel_goal'
  final String factKey;
  final String factValue;
  final int confidenceScore;

  const LearnerFact({
    required this.category,
    required this.factKey,
    required this.factValue,
    this.confidenceScore = 1,
  });
}

/// Zero-cloud local conversational memory graph personalizing future dialogues.
class ConversationalMemoryGraph {
  final Map<String, LearnerFact> _facts = {};

  int get totalFacts => _facts.length;

  /// Ingests an extracted personal declaration (e.g. "Ich spiele gern Fußball").
  void rememberFact({required String category, required String key, required String value}) {
    final normalizedKey = key.trim().toLowerCase();
    final existing = _facts[normalizedKey];

    _facts[normalizedKey] = LearnerFact(
      category: category,
      factKey: normalizedKey,
      factValue: value.trim(),
      confidenceScore: (existing?.confidenceScore ?? 0) + 1,
    );
  }

  /// Retrieves facts relevant to a conversational topic for contextual grounding.
  List<LearnerFact> getRelevantFacts(String topic) {
    final lower = topic.toLowerCase();
    return _facts.values.where((f) {
      return f.category.toLowerCase().contains(lower) ||
          f.factKey.contains(lower) ||
          f.factValue.toLowerCase().contains(lower);
    }).toList();
  }

  /// Generates a personalized prompt context snippet.
  String buildPersonalizationSnippet() {
    if (_facts.isEmpty) return '';
    final buffer = StringBuffer('LEARNER PERSONAL CONTEXT:\n');
    for (final f in _facts.values) {
      buffer.writeln('- ${f.category}: ${f.factValue}');
    }
    return buffer.toString().trim();
  }
}
