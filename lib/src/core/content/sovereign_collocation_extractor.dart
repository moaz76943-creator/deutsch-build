/// Represents a multi-word expression (MWE) or idiom in German and Arabic.
class SovereignCollocation {
  final String germanIdiom;
  final String arabicMeaning;
  final String contextExample;

  const SovereignCollocation({
    required this.germanIdiom,
    required this.arabicMeaning,
    required this.contextExample,
  });
}

/// Offline rule-based collocation and idiomatic phrase extractor.
/// Identifies fixed multi-word phrases and maps them to cultural Arabic equivalents.
class SovereignCollocationExtractor {
  static const List<SovereignCollocation> _curatedCollocations = [
    SovereignCollocation(
      germanIdiom: 'feierabend machen',
      arabicMeaning: 'ينهي عمل اليوم / يستريح بعد الدوام',
      contextExample: 'Ich mache jetzt Feierabend.',
    ),
    SovereignCollocation(
      germanIdiom: 'daumen druecken',
      arabicMeaning: 'يتمنى له التوفيق والنجاح',
      contextExample: 'Ich drücke dir die Daumen.',
    ),
    SovereignCollocation(
      germanIdiom: 'bescheid sagen',
      arabicMeaning: 'يخبر / يعطي علماً مسبقاً',
      contextExample: 'Sag mir bitte Bescheid.',
    ),
    SovereignCollocation(
      germanIdiom: 'in betracht ziehen',
      arabicMeaning: 'يأخذ بعين الاعتبار',
      contextExample: 'Wir müssen das in Betracht ziehen.',
    ),
  ];

  /// Find all recognized collocations in a given sentence.
  static List<SovereignCollocation> extractCollocations(String sentence) {
    if (sentence.isEmpty) return const [];
    final lower = sentence.trim().toLowerCase()
        .replaceAll('ü', 'ue')
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe');

    final matches = <SovereignCollocation>[];
    for (final col in _curatedCollocations) {
      if (lower.contains(col.germanIdiom)) {
        matches.add(col);
      }
    }
    return matches;
  }
}
