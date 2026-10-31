/// Multi-script phonetic transliteration matcher (e.g., Arabizi / Latin to Arabic).
class MultiScriptTransliterationMatcher {
  static const Map<String, String> _arabiziMap = {
    '3': 'ع',
    '7': 'ح',
    '2': 'ء',
    '5': 'خ',
    'kh': 'خ',
    'sh': 'ش',
    'th': 'ث',
    'gh': 'غ',
    'a': 'ا',
    'b': 'ب',
    't': 'ت',
    'j': 'ج',
    'd': 'د',
    'r': 'ر',
    'z': 'ز',
    's': 'س',
    'f': 'ف',
    'q': 'ق',
    'k': 'ك',
    'l': 'ل',
    'm': 'م',
    'n': 'ن',
    'h': 'ه',
    'w': 'و',
    'y': 'ي',
    'i': 'ي',
    'u': 'و',
    'o': 'و',
  };

  /// Transliterates informal Latinized Arabizi queries into target Arabic script.
  String transliterateArabizi(String input) {
    String clean = input.trim().toLowerCase();
    // Multi-char mappings first
    clean = clean.replaceAll('kh', 'خ');
    clean = clean.replaceAll('sh', 'ش');
    clean = clean.replaceAll('th', 'ث');
    clean = clean.replaceAll('gh', 'غ');

    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      final ch = clean[i];
      if (_arabiziMap.containsKey(ch)) {
        buffer.write(_arabiziMap[ch]);
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  /// Calculates phonetic similarity score between query and candidate.
  double matchQuery({required String query, required String candidate}) {
    final transliterated = transliterateArabizi(query);
    final cleanCandidate = candidate.trim().toLowerCase();

    if (cleanCandidate == query.toLowerCase() || cleanCandidate == transliterated) {
      return 1.0;
    }

    if (cleanCandidate.contains(transliterated) || transliterated.contains(cleanCandidate)) {
      return 0.85;
    }

    return 0.0;
  }
}
