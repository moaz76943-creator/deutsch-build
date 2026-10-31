/// Deconstructed morphological decomposition of a target word.
class MorphologicalBreakdown {
  final String originalWord;
  final String root;
  final List<String> prefixes;
  final List<String> suffixes;
  final String wordClass;
  final List<String> derivedFamily;

  const MorphologicalBreakdown({
    required this.originalWord,
    required this.root,
    required this.prefixes,
    required this.suffixes,
    required this.wordClass,
    required this.derivedFamily,
  });
}

/// Deconstructs fusional and agglutinative words into morphological components.
class MorphologicalRootMatrix {
  static const Map<String, List<String>> _germanPrefixes = {
    'ver': ['unaccented', 'transformation/error'],
    'ent': ['unaccented', 'separation/removal'],
    'be': ['unaccented', 'transitive/focus'],
    'auf': ['separable', 'upward/open'],
    'ab': ['separable', 'down/off'],
  };

  static const Map<String, String> _germanSuffixes = {
    'heit': 'abstract_noun_fem',
    'keit': 'abstract_noun_fem',
    'ung': 'action_noun_fem',
    'lich': 'adjective',
    'bar': 'potential_adjective',
    'en': 'verb_infinitive_or_plural',
  };

  /// Analyzes a word and strips affixes to extract its conceptual lemma core.
  MorphologicalBreakdown deconstruct(String word, {List<String> knownFamily = const []}) {
    final lower = word.trim().toLowerCase();
    String current = lower;
    final prefixesFound = <String>[];
    final suffixesFound = <String>[];

    // Detect prefixes
    for (final p in _germanPrefixes.keys) {
      if (current.startsWith(p) && current.length > p.length + 2) {
        prefixesFound.add(p);
        current = current.substring(p.length);
        break;
      }
    }

    // Detect suffixes
    for (final s in _germanSuffixes.keys) {
      if (current.endsWith(s) && current.length > s.length + 2) {
        suffixesFound.add(s);
        current = current.substring(0, current.length - s.length);
        break;
      }
    }

    String wordClass = 'noun';
    if (suffixesFound.contains('lich') || suffixesFound.contains('bar')) {
      wordClass = 'adjective';
    } else if (suffixesFound.contains('ung') || suffixesFound.contains('heit') || suffixesFound.contains('keit')) {
      wordClass = 'noun';
    } else if (lower.endsWith('en') && prefixesFound.isNotEmpty) {
      wordClass = 'verb';
    }

    return MorphologicalBreakdown(
      originalWord: word,
      root: current,
      prefixes: prefixesFound,
      suffixes: suffixesFound,
      wordClass: wordClass,
      derivedFamily: knownFamily,
    );
  }

  /// Calculates morphological complexity score (0.0 to 1.0)
  double calculateComplexity(MorphologicalBreakdown breakdown) {
    int affixCount = breakdown.prefixes.length + breakdown.suffixes.length;
    return (affixCount * 0.25 + (breakdown.root.length > 7 ? 0.3 : 0.1)).clamp(0.0, 1.0);
  }
}
