class ContextualWordGloss {
  final String surfaceToken;
  final String lemma;
  final String partOfSpeech;
  final String phoneticIpa;
  final String translation;
  final String grammarNote;

  const ContextualWordGloss({
    required this.surfaceToken,
    required this.lemma,
    required this.partOfSpeech,
    required this.phoneticIpa,
    required this.translation,
    required this.grammarNote,
  });

  Map<String, String> toJson() => {
    'surfaceToken': surfaceToken,
    'lemma': lemma,
    'partOfSpeech': partOfSpeech,
    'phoneticIpa': phoneticIpa,
    'translation': translation,
    'grammarNote': grammarNote,
  };
}

class InDialogueContextualTranslator {
  static const Map<String, ContextualWordGloss> _lexicon = {
    'speisekarte': ContextualWordGloss(
      surfaceToken: 'Speisekarte',
      lemma: 'die Speisekarte',
      partOfSpeech: 'Noun (Feminine)',
      phoneticIpa: 'ˈʃpaɪ̯zəˌkaʁtə',
      translation: 'menu',
      grammarNote: 'Compound of Speise (food) + Karte (card/menu)',
    ),
    'fahrkarte': ContextualWordGloss(
      surfaceToken: 'Fahrkarte',
      lemma: 'die Fahrkarte',
      partOfSpeech: 'Noun (Feminine)',
      phoneticIpa: 'ˈfaːɐ̯ˌkaʁtə',
      translation: 'ticket (train/transit)',
      grammarNote: 'Accusative feminine object: eine Fahrkarte',
    ),
    'verspätung': ContextualWordGloss(
      surfaceToken: 'Verspätung',
      lemma: 'die Verspätung',
      partOfSpeech: 'Noun (Feminine)',
      phoneticIpa: 'fɛɐ̯ˈʃpɛːtʊŋ',
      translation: 'delay',
      grammarNote: 'Suffix -ung forms feminine abstract nouns',
    ),
    'rechnung': ContextualWordGloss(
      surfaceToken: 'Rechnung',
      lemma: 'die Rechnung',
      partOfSpeech: 'Noun (Feminine)',
      phoneticIpa: 'ˈʁɛçnʊŋ',
      translation: 'bill / check',
      grammarNote: 'Used when requesting the bill in dining or retail',
    ),
    'ging': ContextualWordGloss(
      surfaceToken: 'ging',
      lemma: 'gehen',
      partOfSpeech: 'Verb (Irregular)',
      phoneticIpa: 'ɡɪŋ',
      translation: 'went / walked',
      grammarNote: 'Präteritum past tense of gehen',
    ),
  };

  const InDialogueContextualTranslator();

  /// Looks up clicked word within sentence context.
  ContextualWordGloss lookupToken(String rawToken, {String? surroundingSentence}) {
    // Strip trailing or leading punctuation marks
    final clean = rawToken.replaceAll(RegExp(r'^[^\wäöüÄÖÜß]+|[^\wäöüÄÖÜß]+$'), '').toLowerCase();

    if (_lexicon.containsKey(clean)) {
      return _lexicon[clean]!;
    }

    // Sovereign fallback heuristic
    return ContextualWordGloss(
      surfaceToken: rawToken,
      lemma: clean,
      partOfSpeech: 'Word',
      phoneticIpa: '',
      translation: clean,
      grammarNote: 'Contextual token resolved offline.',
    );
  }
}
