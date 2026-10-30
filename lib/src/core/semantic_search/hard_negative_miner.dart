/// Type of confusion between target word and candidate distractor.
enum ConfusionType {
  semanticNearSynonym, // e.g. kennen vs wissen
  phoneticMinimalPair, // e.g. fordern vs fördern
  morphosyntacticShift, // e.g. liegen vs legen
}

/// A mined distractor with pedagogical contrast explanation.
class ContrastiveDistractor {
  final String targetWord;
  final String distractorWord;
  final ConfusionType type;
  final double similarityScore;
  final String contrastiveNote;

  const ContrastiveDistractor({
    required this.targetWord,
    required this.distractorWord,
    required this.type,
    required this.similarityScore,
    required this.contrastiveNote,
  });
}

/// Mines hard negative distractors to train learner discrimination between subtly distinct words.
class HardNegativeMiner {
  static const List<ContrastiveDistractor> _catalog = [
    ContrastiveDistractor(
      targetWord: 'wissen',
      distractorWord: 'kennen',
      type: ConfusionType.semanticNearSynonym,
      similarityScore: 0.89,
      contrastiveNote: 'wissen = to know a fact/clause (Ich weiß, dass...); kennen = to be acquainted with a person/place/thing (Ich kenne ihn).',
    ),
    ContrastiveDistractor(
      targetWord: 'fördern',
      distractorWord: 'fordern',
      type: ConfusionType.phoneticMinimalPair,
      similarityScore: 0.94,
      contrastiveNote: 'fördern (with umlaut) = to support/promote; fordern = to demand/claim.',
    ),
    ContrastiveDistractor(
      targetWord: 'legen',
      distractorWord: 'liegen',
      type: ConfusionType.morphosyntacticShift,
      similarityScore: 0.87,
      contrastiveNote: 'legen = transitive action + Accusative (Ich lege das Buch); liegen = static location + Dative (Das Buch liegt dort).',
    ),
  ];

  /// Mines distractors for a given target word.
  List<ContrastiveDistractor> mineDistractors(String word) {
    final lower = word.trim().toLowerCase();
    return _catalog.where((d) => d.targetWord == lower || d.distractorWord == lower).toList();
  }

  /// Calculates distractor difficulty rating (0.0 easy to 1.0 extremely deceptive).
  double calculateDeceptionRating(ContrastiveDistractor distractor) {
    return distractor.similarityScore;
  }
}
