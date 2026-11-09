/// Analysis result of a German relative clause.
class RelativeClauseAnalysis {
  final String relativePronoun;
  final String antecedentNoun;
  final String subordinateClause;
  final bool verbPlacedAtEnd;

  RelativeClauseAnalysis({
    required this.relativePronoun,
    required this.antecedentNoun,
    required this.subordinateClause,
    required this.verbPlacedAtEnd,
  });

  Map<String, dynamic> toJson() => {
        'pronoun': relativePronoun,
        'antecedent': antecedentNoun,
        'clause': subordinateClause,
        'verb_at_end': verbPlacedAtEnd,
      };
}

/// Offline syntactic rule engine for German relative clauses (Relativsätze).
/// Validates relative pronoun selection and verifies terminal verb placement.
class GermanRelativeClauseParser {
  static const Set<String> _relativePronouns = {
    'der',
    'die',
    'das',
    'dem',
    'den',
    'dessen',
    'deren',
    'denen',
  };

  /// Parse complex sentence containing a comma-separated relative clause.
  static RelativeClauseAnalysis? parseRelativeClause(String sentence) {
    if (!sentence.contains(',')) return null;

    final parts = sentence.split(',');
    if (parts.length < 2) return null;

    final mainClause = parts[0].trim();
    final subClause = parts[1].trim().replaceAll(RegExp(r'[.!?]'), '');

    final subTokens = subClause.split(RegExp(r'\s+'));
    if (subTokens.isEmpty) return null;

    final firstToken = subTokens.first.toLowerCase();
    if (!_relativePronouns.contains(firstToken)) return null;

    // Extract antecedent from end of main clause
    final mainTokens = mainClause.split(RegExp(r'\s+'));
    final antecedent = mainTokens.isNotEmpty ? mainTokens.last : '';

    // Check if finite verb is placed at the end of the subordinate clause
    final lastSubToken = subTokens.last.toLowerCase();
    final hasVerbAtEnd = lastSubToken.endsWith('t') ||
        lastSubToken.endsWith('en') ||
        lastSubToken.endsWith('te') ||
        lastSubToken == 'ist' ||
        lastSubToken == 'hat';

    return RelativeClauseAnalysis(
      relativePronoun: firstToken,
      antecedentNoun: antecedent,
      subordinateClause: subClause,
      verbPlacedAtEnd: hasVerbAtEnd,
    );
  }
}
