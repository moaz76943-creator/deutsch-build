enum UniversalGrammaticalCategory {
  noun,
  verb,
  adjective,
  adverb,
  preposition,
  pronoun,
  conjunction,
  particle,
}

class GrammarContract {
  final String wordId;
  final UniversalGrammaticalCategory category;
  final Map<String, String> morphologicalFeatures;

  const GrammarContract({
    required this.wordId,
    required this.category,
    this.morphologicalFeatures = const {},
  });
}
