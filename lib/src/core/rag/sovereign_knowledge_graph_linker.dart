class KnowledgeNode {
  final String id;
  final String label;
  final Map<String, String> localized;
  const KnowledgeNode({required this.id, required this.label, this.localized = const {}});
}

class KnowledgeTriple {
  final String sub;
  final String pred;
  final String obj;
  const KnowledgeTriple({required this.sub, required this.pred, required this.obj});
}

class SovereignKnowledgeGraphLinker {
  final Map<String, KnowledgeNode> _nodes = {};
  final List<KnowledgeTriple> _triples = [];

  void addNode(KnowledgeNode n) => _nodes[n.id] = n;
  void addTriple(KnowledgeTriple t) => _triples.add(t);

  List<KnowledgeTriple> expand(String nodeId) {
    return _triples.where((t) => t.sub == nodeId || t.obj == nodeId).toList();
  }
}
