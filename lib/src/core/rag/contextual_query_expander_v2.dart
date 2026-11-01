class ConversationTurn {
  final String speaker;
  final String text;
  final List<String> salientNouns;
  const ConversationTurn({required this.speaker, required this.text, this.salientNouns = const []});
}

class ExpandedQuery {
  final String originalQuery;
  final String rewrittenQuery;
  final bool wasExpanded;
  const ExpandedQuery({required this.originalQuery, required this.rewrittenQuery, required this.wasExpanded});
}

class ContextualQueryExpanderV2 {
  const ContextualQueryExpanderV2();
  static final Set<String> _pronouns = {'هو', 'هي', 'ذلك', 'تلك', 'قواعدها', 'it', 'its', 'o', 'onun', 'dia', 'itu'};

  ExpandedQuery expandQuery({required String currentQuery, required List<ConversationTurn> history}) {
    if (history.isEmpty || currentQuery.trim().isEmpty) {
      return ExpandedQuery(originalQuery: currentQuery, rewrittenQuery: currentQuery, wasExpanded: false);
    }
    String topic = '';
    for (int i = history.length - 1; i >= 0; i--) {
      if (history[i].salientNouns.isNotEmpty) {
        topic = history[i].salientNouns.last;
        break;
      }
    }
    if (topic.isEmpty) {
      return ExpandedQuery(originalQuery: currentQuery, rewrittenQuery: currentQuery, wasExpanded: false);
    }
    final words = currentQuery.split(' ');
    final expanded = words.map((w) => _pronouns.contains(w.toLowerCase()) ? '$w [$topic]' : w).join(' ');
    return ExpandedQuery(originalQuery: currentQuery, rewrittenQuery: expanded, wasExpanded: expanded != currentQuery);
  }
}
