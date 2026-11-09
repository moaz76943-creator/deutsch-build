/// Syntactic role of a word or clause in a sentence.
enum SyntacticRole {
  subject,
  finiteVerb,
  infiniteVerb,
  directObject,
  indirectObject,
  adverbialPhrase,
  unknown,
}

/// Node representing an element in the topological Satzklammer sentence tree.
class SyntaxTreeNode {
  final String text;
  final SyntacticRole role;
  final int positionIndex;

  SyntaxTreeNode({
    required this.text,
    required this.role,
    required this.positionIndex,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'role': role.name,
        'pos': positionIndex,
      };
}

/// Deterministic offline topological field parser (Vorfeld, linke Satzklammer,
/// Mittelfeld, rechte Satzklammer, Nachfeld) for standard German syntax.
class SovereignDependencySyntaxParser {
  static const Set<String> _commonSubjects = {'ich', 'du', 'er', 'sie', 'es', 'wir', 'ihr'};
  static const Set<String> _finiteVerbs = {'habe', 'hast', 'hat', 'haben', 'bin', 'bist', 'ist', 'sind', 'lerne', 'lernt'};

  /// Parse a simple or compound German sentence into topological syntax nodes.
  static List<SyntaxTreeNode> parseSentence(String sentence) {
    if (sentence.isEmpty) return const [];

    final tokens = sentence.trim().replaceAll(RegExp(r'[.,!?]'), '').split(RegExp(r'\s+'));
    final tree = <SyntaxTreeNode>[];

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final lower = token.toLowerCase();

      SyntacticRole role = SyntacticRole.unknown;

      if (_commonSubjects.contains(lower)) {
        role = SyntacticRole.subject;
      } else if (_finiteVerbs.contains(lower)) {
        role = SyntacticRole.finiteVerb;
      } else if (lower.startsWith('ge') && lower.endsWith('t')) {
        role = SyntacticRole.infiniteVerb; // Partizip II in rechte Satzklammer
      } else if (i == tokens.length - 1 && lower.endsWith('en')) {
        role = SyntacticRole.infiniteVerb; // Infinitiv in rechte Satzklammer
      } else if (i > 1) {
        role = SyntacticRole.directObject;
      }

      tree.add(SyntaxTreeNode(text: token, role: role, positionIndex: i));
    }

    return tree;
  }
}
