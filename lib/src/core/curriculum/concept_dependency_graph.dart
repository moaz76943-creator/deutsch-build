/// A node representing a grammatical or communicative competence unit.
class CompetenceNode {
  final String id;
  final String title;
  final String cefrLevel;
  final List<String> prerequisiteIds;
  final double masteryThreshold;

  const CompetenceNode({
    required this.id,
    required this.title,
    required this.cefrLevel,
    required this.prerequisiteIds,
    this.masteryThreshold = 0.85,
  });
}

/// Directed Acyclic Graph (DAG) ensuring pedagogical prerequisites are satisfied.
class ConceptDependencyGraph {
  final Map<String, CompetenceNode> _nodes = {};

  void registerNode(CompetenceNode node) {
    _nodes[node.id] = node;
  }

  /// Verifies whether a candidate concept is unlocked given mastered competencies.
  bool isUnlocked(String conceptId, Set<String> masteredConceptIds) {
    final node = _nodes[conceptId];
    if (node == null) return false;
    for (final prereq in node.prerequisiteIds) {
      if (!masteredConceptIds.contains(prereq)) {
        return false;
      }
    }
    return true;
  }

  /// Traverses prerequisites and returns missing foundation nodes required to unlock concept.
  List<CompetenceNode> getMissingPrerequisites(String conceptId, Set<String> masteredConceptIds) {
    final node = _nodes[conceptId];
    if (node == null) return [];
    final missing = <CompetenceNode>[];

    for (final prereqId in node.prerequisiteIds) {
      if (!masteredConceptIds.contains(prereqId)) {
        final prereqNode = _nodes[prereqId];
        if (prereqNode != null) missing.add(prereqNode);
      }
    }
    return missing;
  }

  /// Calculates global curriculum completion percentage.
  double calculateProgress(Set<String> masteredConceptIds) {
    if (_nodes.isEmpty) return 0.0;
    int masteredCount = 0;
    for (final id in _nodes.keys) {
      if (masteredConceptIds.contains(id)) masteredCount++;
    }
    return (masteredCount / _nodes.length) * 100.0;
  }
}
