/// A syntactic dependency node representing a token and its grammatical role.
class DependencyNode {
  final int id;
  final String text;
  final String pos;
  final String relation; // nsubj, root, obj, obl, punct, mark
  final int headId;

  const DependencyNode({
    required this.id,
    required this.text,
    required this.pos,
    required this.relation,
    required this.headId,
  });
}

/// Renders lightweight Universal Dependencies (UD) ASCII trees and detects syntactic Satzklammer.
class SyntacticDependencyVisualizer {
  /// Generates a readable ASCII indented dependency tree.
  String renderAsciiTree(List<DependencyNode> nodes) {
    if (nodes.isEmpty) return '(empty tree)';

    final buffer = StringBuffer();
    final root = nodes.firstWhere(
      (n) => n.headId == 0 || n.relation.toLowerCase() == 'root',
      orElse: () => nodes.first,
    );

    buffer.writeln('[ROOT] ${root.text} (${root.pos})');
    _renderChildren(buffer, nodes, root.id, indent: ' ├── ');
    return buffer.toString().trimRight();
  }

  void _renderChildren(StringBuffer buffer, List<DependencyNode> nodes, int parentId, {required String indent}) {
    final children = nodes.where((n) => n.headId == parentId && n.id != parentId).toList();
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final isLast = i == children.length - 1;
      final currentPrefix = isLast ? indent.replaceAll('├──', '└──') : indent;
      buffer.writeln('$currentPrefix${child.relation}: ${child.text} (${child.pos})');

      final nextIndent = isLast ? indent.replaceAll('├──', '    ') : indent;
      _renderChildren(buffer, nodes, child.id, indent: '$nextIndent├── ');
    }
  }

  /// Detects German topological field Satzklammer (sentence bracket between auxiliary and verb participle/infinitive).
  bool hasSatzklammer(List<DependencyNode> nodes) {
    int finiteVerbIdx = -1;
    int nonFiniteVerbIdx = -1;

    for (int i = 0; i < nodes.length; i++) {
      final pos = nodes[i].pos.toUpperCase();
      if ((pos == 'VERB' || pos == 'AUX') && nodes[i].relation == 'root') {
        finiteVerbIdx = i;
      }
      if ((pos == 'VERB') && (nodes[i].relation == 'xcomp' || nodes[i].relation == 'compound:prt')) {
        nonFiniteVerbIdx = i;
      }
    }

    return finiteVerbIdx != -1 && nonFiniteVerbIdx != -1 && (nonFiniteVerbIdx - finiteVerbIdx > 1);
  }
}
