/// Lexical relationship types.
enum ThesaurusRelation { synonym, antonym, hypernym }

/// A related lexical entry with similarity score.
class ThesaurusEntry {
  final String relatedWord;
  final ThesaurusRelation relation;
  final double semanticDistance;

  const ThesaurusEntry({
    required this.relatedWord,
    required this.relation,
    required this.semanticDistance,
  });
}

/// Offline multilingual thesaurus for expanding learner vocabulary and query recall.
class SemanticThesaurusExpander {
  static const Map<String, List<ThesaurusEntry>> _thesaurus = {
    'schnell': [
      ThesaurusEntry(relatedWord: 'rasch', relation: ThesaurusRelation.synonym, semanticDistance: 0.92),
      ThesaurusEntry(relatedWord: 'flott', relation: ThesaurusRelation.synonym, semanticDistance: 0.85),
      ThesaurusEntry(relatedWord: 'langsam', relation: ThesaurusRelation.antonym, semanticDistance: 0.95),
      ThesaurusEntry(relatedWord: 'Geschwindigkeit', relation: ThesaurusRelation.hypernym, semanticDistance: 0.70),
    ],
    'klug': [
      ThesaurusEntry(relatedWord: 'intelligent', relation: ThesaurusRelation.synonym, semanticDistance: 0.94),
      ThesaurusEntry(relatedWord: 'weise', relation: ThesaurusRelation.synonym, semanticDistance: 0.88),
      ThesaurusEntry(relatedWord: 'dumm', relation: ThesaurusRelation.antonym, semanticDistance: 0.96),
    ],
  };

  /// Expands a word with its top synonyms.
  List<String> expandSynonyms(String word) {
    final entries = _thesaurus[word.trim().toLowerCase()];
    if (entries == null) return [];

    return entries
        .where((e) => e.relation == ThesaurusRelation.synonym)
        .map((e) => e.relatedWord)
        .toList();
  }

  /// Retrieves antonyms for contrastive exercises.
  List<String> getAntonyms(String word) {
    final entries = _thesaurus[word.trim().toLowerCase()];
    if (entries == null) return [];

    return entries
        .where((e) => e.relation == ThesaurusRelation.antonym)
        .map((e) => e.relatedWord)
        .toList();
  }
}
