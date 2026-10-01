/// Immutable metadata for one directed lexical deck.
final class DeckMetadata {
  const DeckMetadata({
    required this.deckId,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.cefrLevel,
    required this.version,
    required this.totalCards,
  });

  final String deckId;
  final String sourceLanguage;
  final String targetLanguage;
  final String cefrLevel;
  final String version;
  final int totalCards;
}

/// One optional example sentence attached to a vocabulary card.
final class ExampleSentence {
  const ExampleSentence({
    required this.textSource,
    required this.textTarget,
    this.contextNote,
  });

  final String textSource;
  final String textTarget;
  final String? contextNote;
}

/// Directed lexical card produced from one canonical matrix entry.
final class VocabularyCard {
  const VocabularyCard({
    required this.id,
    required this.term,
    required this.transliteration,
    required this.partOfSpeech,
    required this.definitions,
    required this.exampleSentences,
    this.audioMarker,
  });

  final String id;
  final String term;
  final String transliteration;
  final String partOfSpeech;
  final Map<String, String> definitions;
  final List<ExampleSentence> exampleSentences;
  final String? audioMarker;
}

/// Parsed, validated directed deck.
final class ParsedDeck {
  const ParsedDeck({required this.metadata, required this.cards});

  final DeckMetadata metadata;
  final List<VocabularyCard> cards;
}
