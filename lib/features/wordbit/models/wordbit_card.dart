class WordBitCard {
  final String id;
  final String term;
  final String ipa;
  final String partOfSpeech;
  final String translation;
  final String exampleSentence;
  final String domainName;
  final String bcp47Locale;

  const WordBitCard({
    required this.id,
    required this.term,
    required this.ipa,
    required this.partOfSpeech,
    required this.translation,
    required this.exampleSentence,
    required this.domainName,
    required this.bcp47Locale,
  });
}
