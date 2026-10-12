class WordBitCard {
  final String id;
  final String term;
  final String ipa;
  final String partOfSpeech;
  final String translation;
  final String exampleSentence;
  final String domainName;
  final String bcp47Locale;
  final String sourceLanguageCode;
  final String translationLanguageCode;
  final String grammarNote;
  final String article;
  final String plural;
  final String semanticConceptId;

  const WordBitCard({
    required this.id,
    required this.term,
    required this.ipa,
    required this.partOfSpeech,
    required this.translation,
    required this.exampleSentence,
    required this.domainName,
    required this.bcp47Locale,
    this.sourceLanguageCode = '',
    this.translationLanguageCode = '',
    this.grammarNote = '',
    this.article = '',
    this.plural = '',
    this.semanticConceptId = '',
  });

  factory WordBitCard.fromLexiconRow(
    Map<String, dynamic> row, {
    required String sourceLanguageCode,
  }) {
    String text(Object? value) =>
        value is String ? value.trim() : value?.toString().trim() ?? '';

    final id = text(row['lexeme_id']).isNotEmpty
        ? text(row['lexeme_id'])
        : text(row['id']);
    final term = text(row['display_text']).isNotEmpty
        ? text(row['display_text'])
        : text(row['surface']);
    if (id.isEmpty || term.isEmpty) {
      throw const FormatException('Verified lexicon row lacks identity or text');
    }

    final rawFields = row['fields'];
    final fields = rawFields is Map
        ? Map<String, dynamic>.from(rawFields)
        : <String, dynamic>{};

    String firstText(Iterable<Object?> candidates) {
      for (final value in candidates) {
        final candidate = text(value);
        if (candidate.isNotEmpty) {
          return candidate;
        }
      }
      return '';
    }

    final targetLanguage = firstText(<Object?>[
      row['language_code'],
      row['bcp47_locale'],
    ]);

    return WordBitCard(
      id: id,
      term: term,
      ipa: firstText(<Object?>[fields['ipa'], row['ipa']]),
      partOfSpeech: firstText(<Object?>[
        row['part_of_speech'],
        fields['part_of_speech'],
      ]),
      translation: firstText(<Object?>[
        row['translation_ar'],
        fields['translation_ar'],
        fields['translation'],
      ]),
      exampleSentence: firstText(<Object?>[
        row['sentence'],
        fields['sentence'],
        fields['example'],
      ]),
      domainName: firstText(<Object?>[
        fields['domain'],
        fields['domain_name'],
      ]),
      bcp47Locale: targetLanguage,
      sourceLanguageCode: sourceLanguageCode.trim().toLowerCase(),
      translationLanguageCode: firstText(<Object?>[
        row['translation_language_code'],
        fields['translation_language_code'],
        fields['translationLanguageCode'],
      ]),
      grammarNote: firstText(<Object?>[
        fields['grammar_note'],
        fields['grammarNote'],
      ]),
      article: firstText(<Object?>[
        row['article'],
        fields['article'],
      ]),
      plural: firstText(<Object?>[
        row['plural'],
        fields['plural'],
      ]),
      semanticConceptId: firstText(<Object?>[
        fields['semantic_concept_id'],
        fields['semanticConceptId'],
        row['semantic_concept_id'],
      ]),
    );
  }
}
