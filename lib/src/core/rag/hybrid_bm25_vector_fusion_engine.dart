import 'dart:math' as math;

/// Single document tokenized container for BM25 indexing.
class Bm25Document {
  final String id;
  final String text;
  final List<String> tokens;
  final Map<String, int> termFrequencies;

  Bm25Document({
    required this.id,
    required this.text,
    required this.tokens,
  }) : termFrequencies = _computeTf(tokens);

  static Map<String, int> _computeTf(List<String> tokens) {
    final tf = <String, int>{};
    for (final t in tokens) {
      tf[t] = (tf[t] ?? 0) + 1;
    }
    return tf;
  }

  int get length => tokens.length;
}

/// Lexical BM25 search result item.
class LexicalHit {
  final String docId;
  final double score;
  final int rank;

  const LexicalHit({
    required this.docId,
    required this.score,
    required this.rank,
  });
}

/// Dense semantic vector search hit item.
class VectorHit {
  final String docId;
  final double score;
  final int rank;

  const VectorHit({
    required this.docId,
    required this.score,
    required this.rank,
  });
}

/// Fused multi-channel retrieval result item.
class HybridFusionHit {
  final String docId;
  final double rrfScore;
  final int? lexicalRank;
  final double? lexicalScore;
  final int? vectorRank;
  final double? vectorScore;

  const HybridFusionHit({
    required this.docId,
    required this.rrfScore,
    this.lexicalRank,
    this.lexicalScore,
    this.vectorRank,
    this.vectorScore,
  });
}

/// Sovereign on-device BM25 indexer.
class Bm25Index {
  final double k1;
  final double b;
  final Map<String, Bm25Document> _documents = {};
  final Map<String, int> _docFrequencies = {};
  double _totalDocLength = 0.0;

  Bm25Index({this.k1 = 1.2, this.b = 0.75});

  int get documentCount => _documents.length;
  double get averageDocLength => _documents.isEmpty ? 0.0 : _totalDocLength / _documents.length;

  void addDocument(Bm25Document doc) {
    if (_documents.containsKey(doc.id)) {
      removeDocument(doc.id);
    }
    _documents[doc.id] = doc;
    _totalDocLength += doc.length;

    for (final term in doc.termFrequencies.keys) {
      _docFrequencies[term] = (_docFrequencies[term] ?? 0) + 1;
    }
  }

  void removeDocument(String docId) {
    final doc = _documents.remove(docId);
    if (doc != null) {
      _totalDocLength -= doc.length;
      for (final term in doc.termFrequencies.keys) {
        final count = _docFrequencies[term] ?? 1;
        if (count <= 1) {
          _docFrequencies.remove(term);
        } else {
          _docFrequencies[term] = count - 1;
        }
      }
    }
  }

  /// Calculates Robertson-Spärck Jones IDF.
  double idf(String term) {
    final df = _docFrequencies[term] ?? 0;
    if (df == 0) return 0.0;
    final n = _documents.length;
    // Standard Lucene/BM25 IDF formula with smoothing
    return math.log(1.0 + (n - df + 0.5) / (df + 0.5));
  }

  /// Evaluates query against the corpus and returns scored hits ranked descending.
  List<LexicalHit> search(List<String> queryTokens, {int topK = 50}) {
    if (queryTokens.isEmpty || _documents.isEmpty) return const [];

    final scores = <String, double>{};
    final avgdl = averageDocLength;

    for (final term in queryTokens) {
      final termIdf = idf(term);
      if (termIdf <= 0.0) continue;

      for (final entry in _documents.entries) {
        final doc = entry.value;
        final tf = doc.termFrequencies[term] ?? 0;
        if (tf == 0) continue;

        final numerator = tf * (k1 + 1.0);
        final denominator = tf + k1 * (1.0 - b + b * (doc.length / (avgdl > 0 ? avgdl : 1.0)));
        final termScore = termIdf * (numerator / denominator);

        scores[doc.id] = (scores[doc.id] ?? 0.0) + termScore;
      }
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final hits = <LexicalHit>[];
    for (int i = 0; i < sorted.length; i++) {
      hits.add(LexicalHit(
        docId: sorted[i].key,
        score: sorted[i].value,
        rank: i + 1,
      ));
    }

    if (topK > 0 && hits.length > topK) {
      return hits.sublist(0, topK);
    }
    return hits;
  }
}

/// Hybrid Reciprocal Rank Fusion (RRF) coordinator combining lexical and dense retrievals.
class HybridBm25VectorFusionEngine {
  final int rrfK; // Smoothing constant (standard: 60)
  final double lexicalWeight;
  final double vectorWeight;

  const HybridBm25VectorFusionEngine({
    this.rrfK = 60,
    this.lexicalWeight = 1.0,
    this.vectorWeight = 1.0,
  });

  /// Fuses lexical and vector hits using weighted Reciprocal Rank Fusion:
  /// RRF_Score(d) = w_lex / (k + rank_lex(d)) + w_vec / (k + rank_vec(d))
  List<HybridFusionHit> fuse({
    required List<LexicalHit> lexicalHits,
    required List<VectorHit> vectorHits,
    int topK = 20,
  }) {
    final lexMap = <String, LexicalHit>{for (final h in lexicalHits) h.docId: h};
    final vecMap = <String, VectorHit>{for (final h in vectorHits) h.docId: h};

    final allDocIds = <String>{...lexMap.keys, ...vecMap.keys};
    final fused = <HybridFusionHit>[];

    for (final docId in allDocIds) {
      final lex = lexMap[docId];
      final vec = vecMap[docId];

      double score = 0.0;
      if (lex != null) {
        score += lexicalWeight / (rrfK + lex.rank);
      }
      if (vec != null) {
        score += vectorWeight / (rrfK + vec.rank);
      }

      fused.add(HybridFusionHit(
        docId: docId,
        rrfScore: score,
        lexicalRank: lex?.rank,
        lexicalScore: lex?.score,
        vectorRank: vec?.rank,
        vectorScore: vec?.score,
      ));
    }

    fused.sort((a, b) => b.rrfScore.compareTo(a.rrfScore));

    if (topK > 0 && fused.length > topK) {
      return fused.sublist(0, topK);
    }
    return fused;
  }
}
