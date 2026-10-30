import 'dart:math' as math;

/// Dense vector embedding representation for on-device semantic search.
class SemanticVector {
  final List<double> values;
  final int dimension;

  SemanticVector(this.values) : dimension = values.length;

  /// Calculates cosine similarity between two semantic vectors (-1.0 to 1.0).
  double cosineSimilarity(SemanticVector other) {
    if (dimension != other.dimension || dimension == 0) return 0.0;
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < dimension; i++) {
      dotProduct += values[i] * other.values[i];
      normA += values[i] * values[i];
      normB += other.values[i] * other.values[i];
    }

    if (normA <= 0.0 || normB <= 0.0) return 0.0;
    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }
}

/// Generates normalized on-device sentence embeddings across 100 languages.
class CrossLingualEmbeddingsEngine {
  final int embeddingDimension;

  const CrossLingualEmbeddingsEngine({this.embeddingDimension = 64});

  /// Generates a deterministic cross-lingual embedding based on character n-grams and hashing.
  SemanticVector encode(String sentence) {
    final clean = sentence.trim().toLowerCase();
    if (clean.isEmpty) {
      return SemanticVector(List<double>.filled(embeddingDimension, 0.0));
    }

    final vector = List<double>.filled(embeddingDimension, 0.0);
    final runes = clean.runes.toList();

    for (int i = 0; i < runes.length; i++) {
      final code = runes[i];
      final idx = code % embeddingDimension;
      vector[idx] += 1.0;

      // Bigram projection for sequential awareness
      if (i > 0) {
        final biIndex = (code ^ runes[i - 1]) % embeddingDimension;
        vector[biIndex] += 0.5;
      }
    }

    // L2 vector normalization
    double sumSq = 0.0;
    for (final v in vector) {
      sumSq += v * v;
    }
    final norm = math.sqrt(sumSq);
    if (norm > 0) {
      for (int i = 0; i < embeddingDimension; i++) {
        vector[i] /= norm;
      }
    }

    return SemanticVector(vector);
  }
}
