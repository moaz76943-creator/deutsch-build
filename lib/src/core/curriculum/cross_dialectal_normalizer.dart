/// Regional standard variant representation.
class DialectalVariant {
  final String standardWord;
  final String targetDialect; // e.g., 'de-AT' (Austrian), 'de-CH' (Swiss), 'ar-LEV' (Levantine)
  final String regionalVariant;
  final String phoneticDifference;
  final String usageNotes;

  const DialectalVariant({
    required this.standardWord,
    required this.targetDialect,
    required this.regionalVariant,
    required this.phoneticDifference,
    required this.usageNotes,
  });
}

/// Normalizes and alerts learners to regional pluricentric vocabulary shifts.
class CrossDialectalNormalizer {
  static const List<DialectalVariant> _knownVariants = [
    DialectalVariant(
      standardWord: 'Tomate',
      targetDialect: 'de-AT',
      regionalVariant: 'Paradeiser',
      phoneticDifference: 'Complete lexical substitution',
      usageNotes: 'Ubiquitous in Austrian grocery stores and culinary contexts.',
    ),
    DialectalVariant(
      standardWord: 'Kartoffel',
      targetDialect: 'de-AT',
      regionalVariant: 'Erdapfel',
      phoneticDifference: 'Lexical shift to Southern Germanic root',
      usageNotes: 'Widely used in Austria and parts of Southern Germany (Bavaria).',
    ),
    DialectalVariant(
      standardWord: 'Aprikose',
      targetDialect: 'de-AT',
      regionalVariant: 'Marille',
      phoneticDifference: 'Italian/Romance loan influence in Danube region',
      usageNotes: 'Standard Austrian culinary term (e.g., Marillenknödel).',
    ),
    DialectalVariant(
      standardWord: 'Fahrrad',
      targetDialect: 'de-CH',
      regionalVariant: 'Velo',
      phoneticDifference: 'French loanword with Swiss stress pattern',
      usageNotes: 'Standard term throughout Swiss German cantons.',
    ),
  ];

  /// Finds regional variants for a word in a specific pluricentric dialect.
  List<DialectalVariant> resolveVariants(String word, {String? dialectCode}) {
    final lower = word.trim().toLowerCase();
    return _knownVariants.where((v) {
      final matchesWord = v.standardWord.toLowerCase() == lower;
      final matchesDialect = dialectCode == null || v.targetDialect == dialectCode;
      return matchesWord && matchesDialect;
    }).toList();
  }

  /// Normalizes a sentence by substituting regional variants with standard lemma.
  String normalizeToStandard(String inputSentence) {
    String normalized = inputSentence;
    for (final v in _knownVariants) {
      final pattern = RegExp('\\b${v.regionalVariant}\\b', caseSensitive: false);
      normalized = normalized.replaceAll(pattern, v.standardWord);
    }
    return normalized;
  }
}
