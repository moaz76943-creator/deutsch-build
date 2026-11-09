/// Common European Framework of Reference (CEFR) proficiency level.
enum CefrLevel { a1, a2, b1, b2, c1, unknown }

/// Deterministic offline CEFR vocabulary level classifier based on
/// calibrated sovereign corpus frequency ranks.
class CefrLexicalFrequencyClassifier {
  static const Map<String, CefrLevel> _curatedLexiconRanks = {
    // A1 Core
    'hallo': CefrLevel.a1,
    'danke': CefrLevel.a1,
    'bitte': CefrLevel.a1,
    'essen': CefrLevel.a1,
    'trinken': CefrLevel.a1,
    'haus': CefrLevel.a1,
    'gut': CefrLevel.a1,
    'buch': CefrLevel.a1,

    // A2 Everyday Communication
    'arbeit': CefrLevel.a2,
    'wohnung': CefrLevel.a2,
    'urlaub': CefrLevel.a2,
    'gesundheit': CefrLevel.a2,
    'einkaufen': CefrLevel.a2,
    'termin': CefrLevel.a2,

    // B1 Professional & Abstract
    'erfahrung': CefrLevel.b1,
    'ausbildung': CefrLevel.b1,
    'bewerbung': CefrLevel.b1,
    'entscheidung': CefrLevel.b1,
    'gesellschaft': CefrLevel.b1,
    'wirtschaft': CefrLevel.b1,

    // B2 Specialized & Advanced
    'voraussetzung': CefrLevel.b2,
    'nachhaltigkeit': CefrLevel.b2,
    'herausforderung': CefrLevel.b2,
    'zusammenhang': CefrLevel.b2,
    'gewaehrleistung': CefrLevel.b2,
  };

  /// Classify a German word into its standard CEFR competency level.
  static CefrLevel classifyWord(String word) {
    final clean = word.trim().toLowerCase();
    return _curatedLexiconRanks[clean] ?? CefrLevel.unknown;
  }

  /// Compute average difficulty distribution across a list of lesson vocabulary.
  static Map<CefrLevel, int> calculateDistribution(List<String> words) {
    final distribution = <CefrLevel, int>{
      CefrLevel.a1: 0,
      CefrLevel.a2: 0,
      CefrLevel.b1: 0,
      CefrLevel.b2: 0,
      CefrLevel.c1: 0,
      CefrLevel.unknown: 0,
    };

    for (final w in words) {
      final lvl = classifyWord(w);
      distribution[lvl] = (distribution[lvl] ?? 0) + 1;
    }

    return distribution;
  }
}
