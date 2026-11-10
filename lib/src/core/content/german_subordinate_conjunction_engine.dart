/// Semantic category of the German subordinate conjunction.
enum ConjunctionCategory {
  kausal,      // weil, da
  konzessiv,   // obwohl, obgleich
  konditional, // wenn, falls
  finalClause, // damit, um zu
  modalClause, // indem, dadurch dass
  konsekutiv,  // sodass, so dass
  temporal,    // als, waehrend, bevor, nachdem, seitdem, bis
}

/// Order of clauses in the complex sentence.
enum ClausePosition { mainFirst, subordinateFirst }

/// Analysis descriptor of a constructed subordinate sentence pair.
class SubordinateSentenceStructure {
  final String conjunction;
  final ConjunctionCategory category;
  final String mainClauseSubject;
  final String mainClauseVerb;
  final String mainClauseRemainder;
  final String subClauseSubject;
  final String subClauseVerb;
  final String subClauseRemainder;
  final ClausePosition position;
  final String generatedComplexSentence;

  SubordinateSentenceStructure({
    required this.conjunction,
    required this.category,
    required this.mainClauseSubject,
    required this.mainClauseVerb,
    required this.mainClauseRemainder,
    required this.subClauseSubject,
    required this.subClauseVerb,
    required this.subClauseRemainder,
    required this.position,
    required this.generatedComplexSentence,
  });

  Map<String, dynamic> toJson() => {
        'conjunction': conjunction,
        'category': category.name,
        'position': position.name,
        'sentence': generatedComplexSentence,
      };
}

/// Offline rule engine for German subordinating conjunctions (Subjunktionen).
/// Enforces terminal verb placement (Verbletztstellung) in subordinate clauses
/// and main-clause inversion (Verb-Subject) when the subordinate clause appears first.
class GermanSubordinateConjunctionEngine {
  static const Map<String, ConjunctionCategory> _conjunctionDirectory = {
    'weil': ConjunctionCategory.kausal,
    'da': ConjunctionCategory.kausal,
    'obwohl': ConjunctionCategory.konzessiv,
    'obgleich': ConjunctionCategory.konzessiv,
    'wenn': ConjunctionCategory.konditional,
    'falls': ConjunctionCategory.konditional,
    'damit': ConjunctionCategory.finalClause,
    'indem': ConjunctionCategory.modalClause,
    'sodass': ConjunctionCategory.konsekutiv,
    'als': ConjunctionCategory.temporal,
    'waehrend': ConjunctionCategory.temporal,
    'während': ConjunctionCategory.temporal,
    'bevor': ConjunctionCategory.temporal,
    'nachdem': ConjunctionCategory.temporal,
    'seitdem': ConjunctionCategory.temporal,
    'bis': ConjunctionCategory.temporal,
  };

  /// Build a grammatically verified complex sentence with correct verb placements.
  static SubordinateSentenceStructure buildSentence({
    required String conjunction,
    required String mainSubject,
    required String mainVerb,
    required String mainRemainder,
    required String subSubject,
    required String subVerb,
    required String subRemainder,
    ClausePosition position = ClausePosition.mainFirst,
  }) {
    final cleanConj = conjunction.trim().toLowerCase();
    final category = _conjunctionDirectory[cleanConj] ?? ConjunctionCategory.kausal;

    // Subordinate clause: Conjunction + Subject + Remainder + Finite Verb (at the end)
    final subClauseTokens = [
      cleanConj,
      subSubject.trim(),
      if (subRemainder.trim().isNotEmpty) subRemainder.trim(),
      subVerb.trim(),
    ];
    final subClause = subClauseTokens.join(' ');

    String fullSentence = '';

    if (position == ClausePosition.mainFirst) {
      // Main clause: Subject + Finite Verb + Remainder, comma, Subordinate clause.
      final mainClauseTokens = [
        mainSubject.trim(),
        mainVerb.trim(),
        if (mainRemainder.trim().isNotEmpty) mainRemainder.trim(),
      ];
      final mainClause = mainClauseTokens.join(' ');
      fullSentence = '$mainClause, $subClause.';
    } else {
      // Subordinate clause first (Vorfeld): Subordinate clause, comma, Finite Verb + Subject + Remainder (Inversion).
      final mainClauseTokens = [
        mainVerb.trim(),
        mainSubject.trim().toLowerCase(),
        if (mainRemainder.trim().isNotEmpty) mainRemainder.trim(),
      ];
      final mainClauseInverted = mainClauseTokens.join(' ');
      final capitalizedSubClause = subClause[0].toUpperCase() + subClause.substring(1);
      fullSentence = '$capitalizedSubClause, $mainClauseInverted.';
    }

    return SubordinateSentenceStructure(
      conjunction: cleanConj,
      category: category,
      mainClauseSubject: mainSubject,
      mainClauseVerb: mainVerb,
      mainClauseRemainder: mainRemainder,
      subClauseSubject: subSubject,
      subClauseVerb: subVerb,
      subClauseRemainder: subRemainder,
      position: position,
      generatedComplexSentence: fullSentence,
    );
  }
}
