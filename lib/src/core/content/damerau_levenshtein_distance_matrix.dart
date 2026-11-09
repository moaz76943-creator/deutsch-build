import 'dart:math';

/// Memory-bounded Damerau-Levenshtein distance calculator.
/// Handles deletions, insertions, substitutions, and adjacent transpositions (e.g. "ei" <-> "ie").
class DamerauLevenshteinDistanceMatrix {
  /// Compute edit distance with 3-row memory footprint to avoid allocating large 2D tables.
  static int computeDistance(String source, String target) {
    if (source == target) return 0;
    if (source.isEmpty) return target.length;
    if (target.isEmpty) return source.length;

    final s = source.toLowerCase();
    final t = target.toLowerCase();

    final m = s.length;
    final n = t.length;

    List<int> twoRowsBack = List<int>.filled(n + 1, 0);
    List<int> oneRowBack = List<int>.generate(n + 1, (i) => i);
    List<int> currentRow = List<int>.filled(n + 1, 0);

    for (int i = 1; i <= m; i++) {
      currentRow[0] = i;
      for (int j = 1; j <= n; j++) {
        final cost = (s[i - 1] == t[j - 1]) ? 0 : 1;

        int minCost = min(
          currentRow[j - 1] + 1, // insertion
          min(
            oneRowBack[j] + 1, // deletion
            oneRowBack[j - 1] + cost, // substitution
          ),
        );

        // Transposition check
        if (i > 1 && j > 1 && s[i - 1] == t[j - 2] && s[i - 2] == t[j - 1]) {
          minCost = min(minCost, twoRowsBack[j - 2] + 1);
        }

        currentRow[j] = minCost;
      }

      twoRowsBack = List<int>.from(oneRowBack);
      oneRowBack = List<int>.from(currentRow);
    }

    return currentRow[n];
  }

  /// Returns true if typo is within 1 edit (ideal for typo forgiveness in vocab quizzes).
  static bool isMinorTypo(String answer, String expected) {
    return computeDistance(answer, expected) <= 1;
  }
}
