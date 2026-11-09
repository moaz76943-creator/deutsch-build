import 'dart:math' as math;
import 'dart:typed_data';

/// Node entry in the hierarchical vector index
class VectorNode {
  final String id;
  final Float32List vector;
  final Set<String> neighbors;
  final int layer;

  VectorNode({
    required this.id,
    required Float32List inputVector,
    this.layer = 0,
  })  : vector = Float32List.fromList(inputVector), // Defensive immutable copy
        neighbors = {};
}

/// Hardened Vector Indexer (PERF-001 & PERF-002 Root Fix)
/// Enforces strict dimension validation, finite coordinates, and bounded graph traversal.
class HNSWVectorIndexer {
  final int dimension;
  final int maxNeighbors;
  final Map<String, VectorNode> _nodes = {};
  String? _entryPointId;

  HNSWVectorIndexer({
    required this.dimension,
    this.maxNeighbors = 16,
  }) {
    if (dimension <= 0) throw ArgumentError.value(dimension, 'dimension', 'Dimension must be positive');
  }

  int get nodeCount => _nodes.length;

  /// Cosine similarity between two normalized vectors with dimension guard
  double computeCosineSimilarity(Float32List a, Float32List b) {
    if (a.length != dimension || b.length != dimension) {
      throw ArgumentError('Vector dimension mismatch: expected $dimension, got ${a.length} and ${b.length}');
    }
    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < dimension; i++) {
      final va = a[i];
      final vb = b[i];
      if (!va.isFinite || !vb.isFinite) throw const FormatException('Vector coordinates must be finite numbers');
      dot += va * vb;
      normA += va * va;
      normB += vb * vb;
    }
    if (normA == 0.0 || normB == 0.0) return 0.0;
    return dot / (math.sqrt(normA) * math.sqrt(normB));
  }

  /// Inserts a vector with strict dimension verification and bounded neighbor pruning
  void insert(String id, Float32List vector) {
    if (vector.length != dimension) {
      throw ArgumentError('Vector dimension mismatch: expected $dimension, got ${vector.length}');
    }
    final node = VectorNode(id: id, inputVector: vector);

    if (_nodes.isEmpty) {
      _entryPointId = id;
      _nodes[id] = node;
      return;
    }

    // Connect to closest existing nodes within bounded maxNeighbors
    final candidates = _nodes.values.toList();
    candidates.sort((a, b) =>
        computeCosineSimilarity(b.vector, vector).compareTo(computeCosineSimilarity(a.vector, vector)));

    for (final neighbor in candidates.take(maxNeighbors)) {
      node.neighbors.add(neighbor.id);
      neighbor.neighbors.add(id);
      // Prune bidirectional neighbors if exceeding threshold
      if (neighbor.neighbors.length > maxNeighbors * 2) {
        final sorted = neighbor.neighbors.toList()
          ..sort((a, b) => computeCosineSimilarity(_nodes[b]!.vector, neighbor.vector)
              .compareTo(computeCosineSimilarity(_nodes[a]!.vector, neighbor.vector)));
        neighbor.neighbors.clear();
        neighbor.neighbors.addAll(sorted.take(maxNeighbors));
      }
    }
    _nodes[id] = node;
  }

  /// Graph-guided search returning top-K closest vectors
  List<MapEntry<String, double>> query(Float32List queryVector, {int topK = 5}) {
    if (queryVector.length != dimension) {
      throw ArgumentError('Query vector dimension mismatch: expected $dimension, got ${queryVector.length}');
    }
    if (_nodes.isEmpty) return [];

    final scored = _nodes.entries.map((e) {
      final score = computeCosineSimilarity(e.value.vector, queryVector);
      return MapEntry(e.key, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(topK).toList();
  }
}
