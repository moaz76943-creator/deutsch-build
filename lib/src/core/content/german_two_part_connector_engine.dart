/// Type of semantic relationship represented by the two-part connector.
enum TwoPartConnectorType {
  copulative,   // sowohl ... als auch / nicht nur ... sondern auch
  disjunctive,  // entweder ... oder
  negative,     // weder ... noch
  adversative,  // zwar ... aber / einerseits ... andererseits
  proportional, // je ... desto / je ... umso
}

/// Analysis descriptor of a constructed two-part connector sentence.
class TwoPartConnectorSentence {
  final String firstPart;
  final String secondPart;
  final TwoPartConnectorType type;
  final String elementA;
  final String elementB;
  final String fullSentence;
  final String arabicExplanation;

  TwoPartConnectorSentence({
    required this.firstPart,
    required this.secondPart,
    required this.type,
    required this.elementA,
    required this.elementB,
    required this.fullSentence,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'first_part': firstPart,
        'second_part': secondPart,
        'type': type.name,
        'elem_a': elementA,
        'elem_b': elementB,
        'sentence': fullSentence,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine constructing and validating German two-part connectors (Zweiteilige Konnektoren).
/// Enforces comma rules, parallel syntactic alignment, and word-order inversions.
class GermanTwoPartConnectorEngine {
  /// Build a standard copulative, disjunctive, or adversative two-part sentence.
  static TwoPartConnectorSentence buildStandardPair({
    required String subject,
    required String finiteVerb,
    required String connectorPair, // e.g. "sowohl_als_auch", "nicht_nur_sondern_auch", "entweder_oder", "weder_noch", "zwar_aber"
    required String elementA,
    required String elementB,
  }) {
    String p1 = '';
    String p2 = '';
    TwoPartConnectorType type = TwoPartConnectorType.copulative;
    String arabic = '';
    String sentence = '';

    switch (connectorPair.toLowerCase().trim()) {
      case 'sowohl_als_auch':
        p1 = 'sowohl';
        p2 = 'als auch';
        type = TwoPartConnectorType.copulative;
        arabic = 'كلا من ... وكذلك ... (معاً)';
        // No comma typically between sowohl and als auch
        sentence = '$subject $finiteVerb $p1 $elementA $p2 $elementB.';
        break;

      case 'nicht_nur_sondern_auch':
        p1 = 'nicht nur';
        p2 = 'sondern auch';
        type = TwoPartConnectorType.copulative;
        arabic = 'ليس فقط ... بل أيضاً ...';
        // Comma required before sondern auch
        sentence = '$subject $finiteVerb $p1 $elementA, $p2 $elementB.';
        break;

      case 'entweder_oder':
        p1 = 'entweder';
        p2 = 'oder';
        type = TwoPartConnectorType.disjunctive;
        arabic = 'إما ... أو ...';
        sentence = '$subject $finiteVerb $p1 $elementA $p2 $elementB.';
        break;

      case 'weder_noch':
        p1 = 'weder';
        p2 = 'noch';
        type = TwoPartConnectorType.negative;
        arabic = 'لا ... ولا ... (نفي مزدوج)';
        sentence = '$subject $finiteVerb $p1 $elementA $p2 $elementB.';
        break;

      case 'zwar_aber':
        p1 = 'zwar';
        p2 = 'aber';
        type = TwoPartConnectorType.adversative;
        arabic = 'صحيح أن ... لكن ...';
        sentence = '$subject $finiteVerb $p1 $elementA, $p2 $elementB.';
        break;

      default:
        throw ArgumentError('Unsupported connector pair: $connectorPair');
    }

    return TwoPartConnectorSentence(
      firstPart: p1,
      secondPart: p2,
      type: type,
      elementA: elementA,
      elementB: elementB,
      fullSentence: sentence,
      arabicExplanation: arabic,
    );
  }

  /// Build proportional connector sentence: "Je [comparative] ..., desto / umso [comparative] ...".
  /// In the je-clause, the verb is at the end (Nebensatz).
  /// In the desto-clause, the finite verb immediately follows the comparative (Inversion).
  static TwoPartConnectorSentence buildProportional({
    required String comparativeA,
    required String subClauseSubject,
    required String subClauseVerb,
    required String comparativeB,
    required String mainClauseVerb,
    required String mainClauseSubject,
    bool useUmso = false,
  }) {
    final secondConnector = useUmso ? 'umso' : 'desto';

    // Je + Comparative + Subject + Verb, desto + Comparative + Verb + Subject.
    final sentence = 'Je $comparativeA $subClauseSubject $subClauseVerb, $secondConnector $comparativeB $mainClauseVerb $mainClauseSubject.';

    return TwoPartConnectorSentence(
      firstPart: 'je',
      secondPart: secondConnector,
      type: TwoPartConnectorType.proportional,
      elementA: '$comparativeA $subClauseSubject $subClauseVerb',
      elementB: '$comparativeB $mainClauseVerb $mainClauseSubject',
      fullSentence: sentence,
      arabicExplanation: 'كلما ... كلما / زاد ... كلما زاد ...',
    );
  }
}
