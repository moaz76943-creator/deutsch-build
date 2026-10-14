class WordBitCard {
  final String id;
  final String term;
  final String ipa;
  final String partOfSpeech;
  final String translation;
  final String exampleSentence;
  final String sourceExampleTranslation;
  final String domainName;
  final String bcp47Locale;
  final String sourceLocale;

  const WordBitCard({
    required this.id,
    required this.term,
    required this.ipa,
    required this.partOfSpeech,
    required this.translation,
    required this.exampleSentence,
    required this.sourceExampleTranslation,
    required this.domainName,
    required this.bcp47Locale,
    required this.sourceLocale,
  });
}
