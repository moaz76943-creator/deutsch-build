import 'dart:math' as math;

/// Node in the HNSW vector graph index.
class HnswNode {
  final String id;
  final List<double> vector;
  final String payloadText;
  final Map<int, List<String>> neighborsByLayer; // layer -> list of neighbor IDs

  HnswNode({
    required this.id,
    required this.vector,
    required this.payloadText,
    Map<int, List<String>>? neighborsByLayer,
  }) : neighborsByLayer = neighborsByLayer ?? {};
}

/// Search match result from vector query.
class VectorSearchResult {
  final String id;
  final String text;
  final double similarity;

  const VectorSearchResult({
    required this.id,
    required this.text,
    required this.similarity,
  });
}

/// On-device HNSW-inspired approximate nearest neighbor vector indexer.
class HnswVectorIndexer {
  final int maxConnectionsPerNode;
  final Map<String, HnswNode> _nodes = {};

  HnswVectorIndexer({this.maxConnectionsPerNode = 8});

  int get totalVectors => _nodes.length;

  /// Cosine distance calculation between two vectors.
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return 0.0;
    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA <= 0.0 || normB <= 0.0) return 0.0;
    return dot / (math.sqrt(normA) * math.sqrt(normB));
  }

  /// Inserts a vector item into the index and connects to nearest existing neighbors.
  void insert({required String id, required List<double> vector, required String text}) {
    final newNode = HnswNode(id: id, vector: vector, payloadText: text);

    if (_nodes.isNotEmpty) {
      // Find nearest neighbors to connect
      final scored = _nodes.values.map((existing) {
        return MapEntry(existing.id, _cosineSimilarity(vector, existing.vector));
      }).toList();

      scored.sort((a, b) => b.value.compareTo(a.value));
      final topNeighbors = scored.take(maxConnectionsPerNode).map((e) => e.key).toList();
      newNode.neighborsByLayer[0] = topNeighbors;

      for (final neighborId in topNeighbors) {
        _nodes[neighborId]?.neighborsByLayer.putIfAbsent(0, () => []).add(id);
      }
    } else {
      newNode.neighborsByLayer[0] = [];
    }

    _nodes[id] = newNode;
  }

  /// Queries the vector space for k-nearest semantic matches.
  List<VectorSearchResult> query({required List<double> queryVector, int topK = 3}) {
    if (_nodes.isEmpty) return [];

    final scored = _nodes.values.map((node) {
      final sim = _cosineSimilarity(queryVector, node.vector);
      return VectorSearchResult(id: node.id, text: node.payloadText, similarity: sim);
    }).toList();

    scored.sort((a, b) => b.similarity.compareTo(a.similarity));
    return scored.take(topK).toList();
  }
}
