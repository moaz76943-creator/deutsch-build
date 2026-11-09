import 'dart:math';

/// Aligned sentence pair in the sovereign translation memory.
class TranslationUnit {
  final String sourceGerman;
  final String targetArabic;
  final double confidenceScore;

  TranslationUnit({
    required this.sourceGerman,
    required this.targetArabic,
    this.confidenceScore = 1.0,
  });
}

/// Offline fuzzy translation memory aligner based on fast bounded Levenshtein distance.
/// Prevents quadratic memory allocation using two-row dynamic programming.
class SovereignTranslationMemoryAligner {
  final List<TranslationUnit> _memory = <TranslationUnit>[];

  int get unitCount => _memory.length;

  void addTranslationPair(String german, String arabic, {double confidence = 1.0}) {
    _memory.add(TranslationUnit(
      sourceGerman: german.trim(),
      targetArabic: arabic.trim(),
      confidenceScore: confidence,
    ));
  }

  /// Compute normalized Levenshtein similarity (0.0 to 1.0) using bounded two-row DP.
  static double computeSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final a = s1.toLowerCase();
    final b = s2.toLowerCase();

    final m = a.length;
    final n = b.length;

    List<int> prev = List<int>.generate(n + 1, (i) => i);
    List<int> curr = List<int>.filled(n + 1, 0);

    for (int i = 1; i <= m; i++) {
      curr[0] = i;
      for (int j = 1; j <= n; j++) {
        final cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
        curr[j] = min(min(curr[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      prev = List<int>.from(curr);
    }

    final distance = prev[n];
    final maxLen = max(m, n);
    return 1.0 - (distance / maxLen);
  }

  /// Search translation memory for closest match above minimum similarity threshold.
  TranslationUnit? findClosestMatch(String queryGerman, {double minThreshold = 0.65}) {
    TranslationUnit? bestMatch;
    double highestScore = 0.0;

    for (final unit in _memory) {
      final sim = computeSimilarity(queryGerman, unit.sourceGerman);
      if (sim > highestScore && sim >= minThreshold) {
        highestScore = sim;
        bestMatch = unit;
      }
    }

    return bestMatch;
  }
}
