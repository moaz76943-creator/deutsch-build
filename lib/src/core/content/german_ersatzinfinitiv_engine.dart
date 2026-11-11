/// Clause type containing the double infinitive.
enum DoubleInfinitiveClauseType { mainClause, subordinateClauseOberfeld }

/// Verb category triggering the replacement infinitive.
enum ReplacementVerbType { modalVerb, perceptionVerb, causativeLassen }

/// Structure representing a verified Ersatzinfinitiv construction.
class ErsatzinfinitivStructure {
  final String governingVerb; // e.g. "können", "müssen", "lassen", "sehen"
  final String governedInfinitive; // e.g. "lesen", "reparieren", "kommen"
  final ReplacementVerbType verbType;
  final DoubleInfinitiveClauseType clauseType;
  final String auxiliary; // e.g. "hat", "habe", "haben"
  final String fullSentence;
  final String arabicExplanation;

  ErsatzinfinitivStructure({
    required this.governingVerb,
    required this.governedInfinitive,
    required this.verbType,
    required this.clauseType,
    required this.auxiliary,
    required this.fullSentence,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'governing_verb': governingVerb,
        'governed_infinitive': governedInfinitive,
        'type': verbType.name,
        'clause': clauseType.name,
        'auxiliary': auxiliary,
        'sentence': fullSentence,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine constructing and validating German Replacement Infinitives (Ersatzinfinitiv / Doppelinfinitiv).
/// Enforces the substitution of Partizip II by the Infinitive in compound past tenses (Perfekt / Plusquamperfekt)
/// and applies Oberfeldumstellung word-order in subordinate clauses (auxiliary precedes the double infinitive).
class GermanErsatzinfinitivEngine {
  static const Set<String> _modalVerbs = {
    'koennen', 'können', 'muessen', 'müssen', 'duerfen', 'dürfen', 'sollen', 'wollen', 'moegen', 'mögen'
  };

  static const Set<String> _perceptionVerbs = {'sehen', 'hoeren', 'hören', 'helfen'};

  /// Construct an Ersatzinfinitiv sentence in Perfekt.
  static ErsatzinfinitivStructure buildSentence({
    required String subject,
    required String auxiliary, // e.g. "hat", "habe", "hatte"
    required String governingVerb, // e.g. "können", "müssen", "lassen"
    required String governedInfinitive, // e.g. "reparieren", "kommen"
    String objectOrComplement = '',
    DoubleInfinitiveClauseType clauseType = DoubleInfinitiveClauseType.mainClause,
    String subordinateConjunction = 'weil',
  }) {
    final cleanGov = governingVerb.trim().toLowerCase();
    final cleanInf = governedInfinitive.trim().toLowerCase();
    final cleanSubj = subject.trim();
    final cleanAux = auxiliary.trim();
    final cleanComp = objectOrComplement.trim();

    ReplacementVerbType vType = ReplacementVerbType.modalVerb;
    if (_modalVerbs.contains(cleanGov)) {
      vType = ReplacementVerbType.modalVerb;
    } else if (cleanGov == 'lassen') {
      vType = ReplacementVerbType.causativeLassen;
    } else if (_perceptionVerbs.contains(cleanGov)) {
      vType = ReplacementVerbType.perceptionVerb;
    }

    String sentence = '';
    String arabic = '';

    final compStr = cleanComp.isNotEmpty ? ' $cleanComp' : '';

    if (clauseType == DoubleInfinitiveClauseType.mainClause) {
      // Main clause: Subject + Auxiliary + [Object] + Governed Infinitive + Governing Infinitive.
      // e.g. "Er hat das Auto reparieren lassen." / "Ich habe das Buch lesen können."
      sentence = '$cleanSubj $cleanAux$compStr $cleanInf $cleanGov.';
      arabic = 'مصدر بديل (Ersatzinfinitiv) في الجملة الرئيسية: يأتي الفعل المساعد في الموقع الثاني والمصدران في النهاية';
    } else {
      // Subordinate clause (Oberfeldumstellung): Conjunction + Subject + [Object] + Auxiliary + Governed Inf + Governing Inf.
      // e.g. "..., weil er das Auto hat reparieren lassen."
      final subTokens = [
        subordinateConjunction.trim(),
        cleanSubj,
        if (cleanComp.isNotEmpty) cleanComp,
        cleanAux, // Auxiliary moves in front of the double infinitive!
        cleanInf,
        cleanGov,
      ];
      sentence = '${subTokens.join(' ')}.';
      arabic = 'مصدر بديل في جملة تابعة (Oberfeldumstellung): يتقدم الفعل المساعد على المصدرين المزدوجين';
    }

    return ErsatzinfinitivStructure(
      governingVerb: cleanGov,
      governedInfinitive: cleanInf,
      verbType: vType,
      clauseType: clauseType,
      auxiliary: cleanAux,
      fullSentence: sentence,
      arabicExplanation: arabic,
    );
  }
}
