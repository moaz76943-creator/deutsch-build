import 'dart:math' as math;

/// Hybrid ranked candidate holding both lexical and dense scores.
class HybridCandidate {
  final String id;
  final String documentText;
  final double bm25Score;
  final double vectorScore;
  final double fusedRankScore;

  const HybridCandidate({
    required this.id,
    required this.documentText,
    required this.bm25Score,
    required this.vectorScore,
    required this.fusedRankScore,
  });
}

/// Fuses sparse keyword BM25 retrieval with dense semantic vectors using Reciprocal Rank Fusion (RRF).
class HybridSearchReRanker {
  final double kRrfConstant;

  const HybridSearchReRanker({this.kRrfConstant = 60.0});

  /// Calculates simplified BM25 score for lexical keyword matching.
  double calculateBm25({
    required String query,
    required String document,
    double k1 = 1.2,
    double b = 0.75,
    double avgDocLen = 20.0,
  }) {
    final qTokens = query.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final dTokens = document.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    if (qTokens.isEmpty || dTokens.isEmpty) return 0.0;

    double score = 0.0;
    final docLen = dTokens.length;

    for (final q in qTokens) {
      final tf = dTokens.where((t) => t == q).length;
      if (tf > 0) {
        final numerator = tf * (k1 + 1.0);
        final denominator = tf + k1 * (1.0 - b + b * (docLen / avgDocLen));
        score += (numerator / denominator);
      }
    }
    return score;
  }

  /// Merges lexical and dense candidate pools via Reciprocal Rank Fusion (RRF).
  List<HybridCandidate> reRank({
    required String query,
    required List<MapEntry<String, String>> documents,
    required Map<String, double> denseVectorScores,
  }) {
    final bm25Scored = <MapEntry<String, double>>[];

    for (final doc in documents) {
      final score = calculateBm25(query: query, document: doc.value);
      bm25Scored.add(MapEntry(doc.key, score));
    }

    // Sort BM25 candidates descending
    bm25Scored.sort((a, b) => b.value.compareTo(a.value));
    final bm25Ranks = <String, int>{};
    for (int i = 0; i < bm25Scored.length; i++) {
      bm25Ranks[bm25Scored[i].key] = i + 1;
    }

    // Sort dense vector candidates descending
    final denseScored = denseVectorScores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final denseRanks = <String, int>{};
    for (int i = 0; i < denseScored.length; i++) {
      denseRanks[denseScored[i].key] = i + 1;
    }

    final fusedList = <HybridCandidate>[];
    for (final doc in documents) {
      final id = doc.key;
      final rankBm25 = bm25Ranks[id] ?? (documents.length + 1);
      final rankDense = denseRanks[id] ?? (documents.length + 1);

      // RRF formula: RRF_score = 1/(k + rank_bm25) + 1/(k + rank_dense)
      final rrf = (1.0 / (kRrfConstant + rankBm25)) + (1.0 / (kRrfConstant + rankDense));

      fusedList.add(HybridCandidate(
        id: id,
        documentText: doc.value,
        bm25Score: bm25Scored.firstWhere((e) => e.key == id, orElse: () => MapEntry(id, 0.0)).value,
        vectorScore: denseVectorScores[id] ?? 0.0,
        fusedRankScore: double.parse(rrf.toStringAsFixed(5)),
      ));
    }

    fusedList.sort((a, b) => b.fusedRankScore.compareTo(a.fusedRankScore));
    return fusedList;
  }
}
