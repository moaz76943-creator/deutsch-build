import 'dart:math' as math;

/// Represents a ranked lexical item with Zipfian metrics and pedagogical priority.
class RankedLexeme {
  final String lemma;
  final int corpusRank;
  final double zipfScore;
  final String cefrTier;
  final double acquisitionPriority;

  const RankedLexeme({
    required this.lemma,
    required this.corpusRank,
    required this.zipfScore,
    required this.cefrTier,
    required this.acquisitionPriority,
  });
}

/// Ranks vocabulary items dynamically using Zipf's Law and dispersion indices.
class LexicalFrequencyRanker {
  /// Estimates Zipf scale score (1.0 = extremely rare, 7.0 = ubiquitous function words)
  static double calculateZipf(int rank, {int corpusSize = 1000000}) {
    if (rank <= 0) return 1.0;
    final score = 7.0 - (math.log(rank) / math.ln10);
    return score.clamp(1.0, 7.0);
  }

  /// Maps a corpus frequency rank to an approximate CEFR tier.
  static String mapRankToCefr(int rank) {
    if (rank <= 600) return 'A1';
    if (rank <= 1500) return 'A2';
    if (rank <= 3000) return 'B1';
    if (rank <= 5500) return 'B2';
    if (rank <= 9000) return 'C1';
    return 'C2';
  }

  /// Evaluates and prioritizes a list of candidate words for the learner's next step.
  List<RankedLexeme> rankCandidateWords(List<MapEntry<String, int>> wordsWithRanks) {
    final ranked = <RankedLexeme>[];

    for (final entry in wordsWithRanks) {
      final lemma = entry.key.trim().toLowerCase();
      final rank = entry.value;
      final zipf = calculateZipf(rank);
      final cefr = mapRankToCefr(rank);
      final priority = zipf * 10.0;

      ranked.add(RankedLexeme(
        lemma: lemma,
        corpusRank: rank,
        zipfScore: double.parse(zipf.toStringAsFixed(2)),
        cefrTier: cefr,
        acquisitionPriority: double.parse(priority.toStringAsFixed(2)),
      ));
    }

    ranked.sort((a, b) => b.acquisitionPriority.compareTo(a.acquisitionPriority));
    return ranked;
  }
}
