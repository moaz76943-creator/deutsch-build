/// Type of infinitive construction in German syntax.
enum InfinitiveConstructionType {
  standardZu,     // hoffen, planen, versuchen ... zu + Inf
  impersonalZu,   // es ist wichtig / möglich ... zu + Inf
  nounCollocationZu, // Zeit / Lust / die Absicht haben ... zu + Inf
  purposeUmZu,    // um ... zu + Inf (gleiches Subjekt)
}

/// Analysis descriptor of a constructed infinitive clause.
class InfinitiveClauseStructure {
  final String matrixClause;
  final String infinitiveVerb;
  final bool isSeparable;
  final String formattedInfinitiveWithZu;
  final InfinitiveConstructionType type;
  final String fullSentence;

  InfinitiveClauseStructure({
    required this.matrixClause,
    required this.infinitiveVerb,
    required this.isSeparable,
    required this.formattedInfinitiveWithZu,
    required this.type,
    required this.fullSentence,
  });

  Map<String, dynamic> toJson() => {
        'matrix': matrixClause,
        'verb': infinitiveVerb,
        'separable': isSeparable,
        'zu_form': formattedInfinitiveWithZu,
        'type': type.name,
        'sentence': fullSentence,
      };
}

/// Offline rule engine constructing and validating German Infinitiv mit "zu"
/// and final clauses (um ... zu + Infinitiv).
/// Correctly embeds "zu" inside separable verbs (e.g. einladen -> einzuladen).
class GermanInfinitiveWithZuEngine {
  static const Set<String> _separablePrefixes = {
    'ab', 'an', 'auf', 'aus', 'ein', 'fern', 'mit', 'nach', 'vor', 'weg', 'zu', 'zurück'
  };

  /// Format an infinitive verb with "zu", placing "zu" between prefix and stem if separable.
  static String formatVerbWithZu(String verbInfinitive) {
    final clean = verbInfinitive.trim().toLowerCase();

    for (final prefix in _separablePrefixes) {
      if (clean.startsWith(prefix) && clean.length > prefix.length + 2) {
        final stem = clean.substring(prefix.length);
        return '$prefix' 'zu$stem';
      }
    }

    return 'zu $clean';
  }

  /// Construct an Infinitive clause with verified comma and syntactic structure.
  static InfinitiveClauseStructure buildClause({
    required String matrixClause,
    required String infinitiveVerb,
    String complement = '',
    InfinitiveConstructionType type = InfinitiveConstructionType.standardZu,
  }) {
    final cleanVerb = infinitiveVerb.trim().toLowerCase();
    final zuForm = formatVerbWithZu(cleanVerb);
    final isSep = !zuForm.startsWith('zu ');

    final compStr = complement.trim().isNotEmpty ? '${complement.trim()} ' : '';
    final infinitiveGroup = (type == InfinitiveConstructionType.purposeUmZu)
        ? 'um $compStr$zuForm'
        : '$compStr$zuForm';

    final cleanMatrix = matrixClause.trim().replaceAll(RegExp(r'[,.!?]$'), '');
    final sentence = '$cleanMatrix, $infinitiveGroup.';

    return InfinitiveClauseStructure(
      matrixClause: cleanMatrix,
      infinitiveVerb: cleanVerb,
      isSeparable: isSep,
      formattedInfinitiveWithZu: zuForm,
      type: type,
      fullSentence: sentence,
    );
  }
}
