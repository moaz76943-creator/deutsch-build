/// Type of subordinate clause linked to the pronominal correlate.
enum CorrelateSubordinateType { dassClause, obClause, infinitiveZu }

/// Obligatory status of the correlate in the matrix clause.
enum CorrelateObligationStatus { mandatory, optional }

/// Structure representing a prepositional correlate construction.
class PrepositionalCorrelateStructure {
  final String verbWithPreposition; // e.g. "warten auf", "abhängen von", "sich freuen auf"
  final String correlatePlaceholder; // e.g. "darauf", "davon", "daran"
  final CorrelateSubordinateType subordinateType;
  final CorrelateObligationStatus obligation;
  final String matrixClause;
  final String subordinateClause;
  final String fullSentence;
  final String arabicExplanation;

  PrepositionalCorrelateStructure({
    required this.verbWithPreposition,
    required this.correlatePlaceholder,
    required this.subordinateType,
    required this.obligation,
    required this.matrixClause,
    required this.subordinateClause,
    required this.fullSentence,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'verb_prep': verbWithPreposition,
        'correlate': correlatePlaceholder,
        'type': subordinateType.name,
        'obligation': obligation.name,
        'matrix': matrixClause,
        'subordinate': subordinateClause,
        'sentence': fullSentence,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine constructing German complex sentences where a pronominal adverb
/// acts as a correlate/placeholder in the main clause for a following subordinate clause or infinitive.
class GermanPrepositionalCorrelateEngine {
  static const Map<String, String> _correlateMap = {
    'warten auf': 'darauf',
    'sich freuen auf': 'darauf',
    'sich freuen ueber': 'darüber',
    'sich freuen über': 'darüber',
    'abhaengen von': 'davon',
    'abhängen von': 'davon',
    'rechnen mit': 'damit',
    'zweifeln an': 'daran',
    'denken an': 'daran',
    'beitragen zu': 'dazu',
    'achten auf': 'darauf',
  };

  /// Build a complex sentence with pronominal correlate.
  static PrepositionalCorrelateStructure buildComplexClause({
    required String subject,
    required String conjugatedVerb,
    required String verbWithPrepositionKey, // e.g. "abhängen von", "sich freuen auf"
    required CorrelateSubordinateType subType,
    required String subClauseContent, // e.g. "du bald kommst" or "ob das Wetter gut ist" or "dich zu sehen"
    bool omitCorrelateIfOptional = false,
  }) {
    final cleanKey = verbWithPrepositionKey.trim().toLowerCase();
    final correlate = _correlateMap[cleanKey] ?? 'darauf';

    // Verbs like "abhängen von", "achten auf", "zweifeln an" require mandatory correlates
    final isMandatory = cleanKey.contains('abhängen') || cleanKey.contains('achten') || cleanKey.contains('zweifeln') || cleanKey.contains('beitragen');
    final obligation = isMandatory ? CorrelateObligationStatus.mandatory : CorrelateObligationStatus.optional;

    String matrix = '';
    if (omitCorrelateIfOptional && !isMandatory) {
      matrix = '$subject $conjugatedVerb'.trim();
    } else {
      matrix = '$subject $conjugatedVerb $correlate'.trim();
    }

    String subClause = '';
    switch (subType) {
      case CorrelateSubordinateType.dassClause:
        subClause = 'dass ${subClauseContent.trim()}';
        break;
      case CorrelateSubordinateType.obClause:
        subClause = 'ob ${subClauseContent.trim()}';
        break;
      case CorrelateSubordinateType.infinitiveZu:
        subClause = subClauseContent.trim();
        break;
    }

    final fullSentence = '$matrix, $subClause.';

    return PrepositionalCorrelateStructure(
      verbWithPreposition: verbWithPrepositionKey,
      correlatePlaceholder: correlate,
      subordinateType: subType,
      obligation: obligation,
      matrixClause: matrix,
      subordinateClause: subClause,
      fullSentence: fullSentence,
      arabicExplanation: 'رابط ظرفي ضميري كعنصر نائب ورابط تمهيدي للجملة التابعة في الجملة الرئيسية',
    );
  }
}
