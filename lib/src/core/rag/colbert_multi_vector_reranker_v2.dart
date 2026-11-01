import 'dart:math' as math;

/// Single token representation in the ColBERT multi-vector space.
class ColbertTokenEmbedding {
  final String token;
  final List<double> vector;
  final double norm;

  ColbertTokenEmbedding({
    required this.token,
    required List<double> rawVector,
  })  : vector = _normalize(rawVector),
        norm = _computeNorm(rawVector);

  static double _computeNorm(List<double> v) {
    double sumSq = 0.0;
    for (int i = 0; i < v.length; i++) {
      sumSq += v[i] * v[i];
    }
    return math.sqrt(sumSq);
  }

  static List<double> _normalize(List<double> v) {
    final n = _computeNorm(v);
    if (n < 1e-12) return List<double>.filled(v.length, 0.0);
    return List<double>.generate(v.length, (i) => v[i] / n);
  }

  /// Fast dot-product between unit vectors (Cosine Similarity).
  double dotProduct(ColbertTokenEmbedding other) {
    assert(vector.length == other.vector.length, 'Vector dimension mismatch');
    double sum = 0.0;
    final len = vector.length;
    for (int i = 0; i < len; i++) {
      sum += vector[i] * other.vector[i];
    }
    return sum;
  }
}

/// Document representation containing sequence of contextual token embeddings.
class ColbertDocumentRecord {
  final String id;
  final String text;
  final String languageCode;
  final List<ColbertTokenEmbedding> tokenEmbeddings;
  final Map<String, dynamic> metadata;

  const ColbertDocumentRecord({
    required this.id,
    required this.text,
    required this.languageCode,
    required this.tokenEmbeddings,
    this.metadata = const {},
  });

  int get tokenCount => tokenEmbeddings.length;
}

/// Re-ranking result score and matched token alignment.
class ColbertRerankResult {
  final ColbertDocumentRecord document;
  final double score;
  final List<TokenAlignmentScore> tokenAlignments;

  const ColbertRerankResult({
    required this.document,
    required this.score,
    required this.tokenAlignments,
  });
}

class TokenAlignmentScore {
  final String queryToken;
  final String bestMatchedDocToken;
  final double maxSimScore;

  const TokenAlignmentScore({
    required this.queryToken,
    required this.bestMatchedDocToken,
    required this.maxSimScore,
  });
}

/// Sovereign on-device implementation of late interaction ColBERT multi-vector re-ranker.
/// Completely autonomous, zero external cloud dependency, optimized for mobile battery & memory.
class ColbertMultiVectorRerankerV2 {
  final int vectorDimension;
  final double minTokenSimFloor;

  const ColbertMultiVectorRerankerV2({
    this.vectorDimension = 64,
    this.minTokenSimFloor = 0.0,
  });

  /// Evaluates query tokens against a list of candidate documents using MaxSim operator.
  /// Score(Q, D) = sum_{q in Q} max_{d in D} (q · d)
  List<ColbertRerankResult> rerank({
    required List<ColbertTokenEmbedding> queryTokens,
    required List<ColbertDocumentRecord> candidateDocuments,
    int topK = 10,
  }) {
    if (queryTokens.isEmpty || candidateDocuments.isEmpty) {
      return const [];
    }

    final results = <ColbertRerankResult>[];

    for (final doc in candidateDocuments) {
      if (doc.tokenEmbeddings.isEmpty) {
        results.add(ColbertRerankResult(
          document: doc,
          score: 0.0,
          tokenAlignments: const [],
        ));
        continue;
      }

      double totalScore = 0.0;
      final alignments = <TokenAlignmentScore>[];

      for (final qToken in queryTokens) {
        double maxSim = -1.0;
        String bestDocToken = '';

        for (final dToken in doc.tokenEmbeddings) {
          final sim = qToken.dotProduct(dToken);
          if (sim > maxSim) {
            maxSim = sim;
            bestDocToken = dToken.token;
          }
        }

        final effectiveScore = math.max(minTokenSimFloor, maxSim);
        totalScore += effectiveScore;
        alignments.add(TokenAlignmentScore(
          queryToken: qToken.token,
          bestMatchedDocToken: bestDocToken,
          maxSimScore: maxSim,
        ));
      }

      results.add(ColbertRerankResult(
        document: doc,
        score: totalScore,
        tokenAlignments: alignments,
      ));
    }

    // Sort descending by total MaxSim score
    results.sort((a, b) => b.score.compareTo(a.score));

    if (topK > 0 && results.length > topK) {
      return results.sublist(0, topK);
    }
    return results;
  }

  /// Helper factory to generate mock unit embeddings for testing or synthetic tokenization.
  static ColbertTokenEmbedding createSyntheticEmbedding(
    String token,
    int dimension,
    int seed,
  ) {
    final rand = math.Random(seed);
    final raw = List<double>.generate(
      dimension,
      (_) => (rand.nextDouble() * 2.0) - 1.0,
    );
    return ColbertTokenEmbedding(token: token, rawVector: raw);
  }
}
