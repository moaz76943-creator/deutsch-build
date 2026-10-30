/// A directed labeled relationship edge in the sovereign knowledge graph.
class GraphEdge {
  final String sourceNode;
  final String relation; // e.g. GOVERNS_CASE, HAS_SYNONYM, REQUIRES_PREREQUISITE
  final String targetNode;
  final double weight;

  const GraphEdge({
    required this.sourceNode,
    required this.relation,
    required this.targetNode,
    this.weight = 1.0,
  });
}

/// Offline semantic graph query engine for multi-hop grammatical and conceptual lookups.
class OfflineGraphQueryEngine {
  final List<GraphEdge> _edges = [];

  void addEdge(GraphEdge edge) {
    _edges.add(edge);
  }

  void addEdges(Iterable<GraphEdge> edges) {
    _edges.addAll(edges);
  }

  int get totalEdges => _edges.length;

  /// Finds all target nodes connected to a source via a specific relation (1-hop).
  List<String> queryTargets({required String source, required String relation}) {
    return _edges
        .where((e) => e.sourceNode.toLowerCase() == source.toLowerCase() && e.relation.toLowerCase() == relation.toLowerCase())
        .map((e) => e.targetNode)
        .toList();
  }

  /// Finds all source nodes that point to a target via a specific relation (incoming edges).
  List<String> querySources({required String target, required String relation}) {
    return _edges
        .where((e) => e.targetNode.toLowerCase() == target.toLowerCase() && e.relation.toLowerCase() == relation.toLowerCase())
        .map((e) => e.sourceNode)
        .toList();
  }

  /// Performs a 2-hop traversal: (source)-[rel1]->(intermediate)-[rel2]->(destination).
  List<String> queryTwoHop({
    required String source,
    required String firstRelation,
    required String secondRelation,
  }) {
    final intermediates = queryTargets(source: source, relation: firstRelation);
    final results = <String>{};

    for (final inter in intermediates) {
      final targets = queryTargets(source: inter, relation: secondRelation);
      results.addAll(targets);
    }

    return results.toList();
  }
}
