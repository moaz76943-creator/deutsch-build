/// Result of separable verb analysis.
class SeparableVerbAnalysis {
  final String originalSentence;
  final String conjugatedStem;
  final String separatedPrefix;
  final String canonicalInfinitive;
  final bool isSeparated;

  SeparableVerbAnalysis({
    required this.originalSentence,
    required this.conjugatedStem,
    required this.separatedPrefix,
    required this.canonicalInfinitive,
    required this.isSeparated,
  });

  Map<String, dynamic> toJson() => {
        'sentence': originalSentence,
        'stem': conjugatedStem,
        'prefix': separatedPrefix,
        'infinitive': canonicalInfinitive,
        'separated': isSeparated,
      };
}

/// Offline rule engine analyzing German separable (trennbare) verbs in main clauses
/// and recombining isolated terminal prefixes with verb stems into dictionary infinitives.
class GermanSeparableVerbRecombiner {
  static const Set<String> _separablePrefixes = {
    'ab',
    'an',
    'auf',
    'aus',
    'ein',
    'fern',
    'mit',
    'nach',
    'vor',
    'weg',
    'zu',
    'zurueck',
    'zurück',
  };

  /// Identify separated verb prefix at sentence end and reconstruct full infinitive.
  static SeparableVerbAnalysis? analyzeSentence(String sentence) {
    if (sentence.isEmpty) return null;

    final clean = sentence.trim().replaceAll(RegExp(r'[.!?]'), '');
    final tokens = clean.split(RegExp(r'\s+'));
    if (tokens.length < 2) return null;

    final lastToken = tokens.last.toLowerCase();
    if (!_separablePrefixes.contains(lastToken)) return null;

    // Typically in main clauses, finite verb is at position 1 (0-indexed) or position 0 in questions
    String stemToken = '';
    for (int i = 0; i < tokens.length - 1; i++) {
      final t = tokens[i].toLowerCase();
      if (t.endsWith('t') || t.endsWith('st') || t.endsWith('e') || t.endsWith('en')) {
        stemToken = t;
        break;
      }
    }

    if (stemToken.isEmpty) return null;

    // Derive approximate infinitive
    String infinitiveStem = stemToken;
    if (stemToken.endsWith('st')) {
      infinitiveStem = '${stemToken.substring(0, stemToken.length - 2)}en';
    } else if (stemToken.endsWith('t')) {
      infinitiveStem = '${stemToken.substring(0, stemToken.length - 1)}en';
    } else if (stemToken.endsWith('e')) {
      infinitiveStem = '${stemToken.substring(0, stemToken.length - 1)}en';
    }

    final fullInfinitive = '$lastToken$infinitiveStem';

    return SeparableVerbAnalysis(
      originalSentence: sentence,
      conjugatedStem: stemToken,
      separatedPrefix: lastToken,
      canonicalInfinitive: fullInfinitive,
      isSeparated: true,
    );
  }
}
