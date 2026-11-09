/// Analysis result of a lemmatized German word.
class LemmatizationResult {
  final String surfaceForm;
  final String lemma;
  final String tense;
  final bool isIrregular;

  LemmatizationResult({
    required this.surfaceForm,
    required this.lemma,
    required this.tense,
    this.isIrregular = false,
  });

  Map<String, dynamic> toJson() => {
        'surface': surfaceForm,
        'lemma': lemma,
        'tense': tense,
        'irregular': isIrregular,
      };
}

/// Offline rule-based lemmatizer mapping inflected German verb forms
/// to dictionary infinitives without reliance on cloud NLP models.
class GermanMorphologicalLemmatizer {
  static const Map<String, String> _irregularVerbMap = {
    'ging': 'gehen',
    'gegangen': 'gehen',
    'geht': 'gehen',
    'sprach': 'sprechen',
    'gesprochen': 'sprechen',
    'spricht': 'sprechen',
    'schrieb': 'schreiben',
    'geschrieben': 'schreiben',
    'schreibt': 'schreiben',
    'sah': 'sehen',
    'gesehen': 'sehen',
    'sieht': 'sehen',
    'nahm': 'nehmen',
    'genommen': 'nehmen',
    'nimmt': 'nehmen',
    'war': 'sein',
    'gewesen': 'sein',
    'ist': 'sein',
    'sind': 'sein',
    'hatte': 'haben',
    'gehabt': 'haben',
    'hat': 'haben',
  };

  /// Lemmatize German surface word to its base canonical form.
  static LemmatizationResult lemmatize(String word) {
    final clean = word.trim().toLowerCase();

    // 1. Direct irregular verb lookup
    if (_irregularVerbMap.containsKey(clean)) {
      return LemmatizationResult(
        surfaceForm: word,
        lemma: _irregularVerbMap[clean]!,
        tense: clean.startsWith('ge') ? 'Partizip_II' : 'Präsens_oder_Präteritum',
        isIrregular: true,
      );
    }

    // 2. Regular Partizip II check: ge-stem-t
    if (clean.startsWith('ge') && clean.endsWith('t') && clean.length > 4) {
      final stem = clean.substring(2, clean.length - 1);
      return LemmatizationResult(
        surfaceForm: word,
        lemma: '${stem}en',
        tense: 'Partizip_II',
      );
    }

    // 3. Regular present tense inflections: -st, -t, -en, -e
    if (clean.endsWith('st') && clean.length > 3) {
      final stem = clean.substring(0, clean.length - 2);
      return LemmatizationResult(surfaceForm: word, lemma: '${stem}en', tense: 'Präsens_Du');
    }
    if (clean.endsWith('t') && clean.length > 2) {
      final stem = clean.substring(0, clean.length - 1);
      return LemmatizationResult(surfaceForm: word, lemma: '${stem}en', tense: 'Präsens_Er_Sie_Es');
    }
    if (clean.endsWith('e') && clean.length > 2) {
      final stem = clean.substring(0, clean.length - 1);
      return LemmatizationResult(surfaceForm: word, lemma: '${stem}en', tense: 'Präsens_Ich');
    }

    // Fallback: word is already base form or unknown
    return LemmatizationResult(surfaceForm: word, lemma: clean, tense: 'Grundform');
  }
}
