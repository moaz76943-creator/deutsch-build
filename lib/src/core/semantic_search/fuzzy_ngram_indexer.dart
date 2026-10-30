import 'dart:math' as math;

/// Fuzzy match hit with edit distance.
class FuzzyMatch {
  final String term;
  final int distance;
  final double similarity;

  const FuzzyMatch({
    required this.term,
    required this.distance,
    required this.similarity,
  });
}

/// Offline fuzzy search engine normalizing umlauts, accents, and typos via Damerau-Levenshtein.
class FuzzyNgramIndexer {
  final Set<String> _vocabulary = {};

  void addWord(String word) {
    if (word.trim().isNotEmpty) {
      _vocabulary.add(word.trim());
    }
  }

  void addAll(Iterable<String> words) {
    for (final w in words) {
      addWord(w);
    }
  }

  /// Normalizes German umlauts and case for fault-tolerant comparison.
  static String normalizeOrthography(String input) {
    return input
        .toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss');
  }

  /// Calculates Damerau-Levenshtein distance (insertions, deletions, substitutions, transpositions).
  static int editDistance(String source, String target) {
    final s = normalizeOrthography(source);
    final t = normalizeOrthography(target);

    final n = s.length;
    final m = t.length;
    if (n == 0) return m;
    if (m == 0) return n;

    final d = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));

    for (int i = 0; i <= n; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= m; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final cost = (s[i - 1] == t[j - 1]) ? 0 : 1;
        d[i][j] = math.min(
          math.min(d[i - 1][j] + 1, d[i][j - 1] + 1),
          d[i - 1][j - 1] + cost,
        );

        // Transposition check
        if (i > 1 && j > 1 && s[i - 1] == t[j - 2] && s[i - 2] == t[j - 1]) {
          d[i][j] = math.min(d[i][j], d[i - 2][j - 2] + 1);
        }
      }
    }
    return d[n][m];
  }

  /// Queries vocabulary returning closest matches within maximum allowable distance.
  List<FuzzyMatch> search(String query, {int maxDistance = 2, int topK = 5}) {
    if (query.trim().isEmpty) return [];

    final matches = <FuzzyMatch>[];
    for (final word in _vocabulary) {
      final dist = editDistance(query, word);
      if (dist <= maxDistance) {
        final maxLen = math.max(query.length, word.length);
        final sim = maxLen > 0 ? (1.0 - (dist / maxLen)) : 1.0;
        matches.add(FuzzyMatch(
          term: word,
          distance: dist,
          similarity: double.parse(sim.toStringAsFixed(2)),
        ));
      }
    }

    matches.sort((a, b) => a.distance.compareTo(b.distance));
    return matches.take(topK).toList();
  }
}
