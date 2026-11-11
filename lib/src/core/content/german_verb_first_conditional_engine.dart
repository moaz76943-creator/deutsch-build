/// Type of conditional clause construction.
enum ConditionalClauseStyle {
  verbFirstSpitzenstellung, // Hätte ich Zeit, ... (V1 ohne wenn)
  standardConjunctionWenn,  // Wenn ich Zeit hätte, ... (V-Letzt mit wenn)
}

/// Analysis descriptor of an engineered verb-first hypothetical conditional.
class VerbFirstConditionalStructure {
  final String conditionVerbFirst; // e.g. "Hätte ich mehr Zeit gehabt"
  final String conditionWennClause; // e.g. "Wenn ich mehr Zeit gehabt hätte"
  final String consequenceMainClause; // e.g. "wäre ich gerne gekommen"
  final String fullV1Sentence;
  final String fullWennSentence;
  final String arabicNuanceExplanation;

  VerbFirstConditionalStructure({
    required this.conditionVerbFirst,
    required this.conditionWennClause,
    required this.consequenceMainClause,
    required this.fullV1Sentence,
    required this.fullWennSentence,
    required this.arabicNuanceExplanation,
  });

  Map<String, dynamic> toJson() => {
        'v1_condition': conditionVerbFirst,
        'wenn_condition': conditionWennClause,
        'consequence': consequenceMainClause,
        'v1_sentence': fullV1Sentence,
        'wenn_sentence': fullWennSentence,
        'arabic': arabicNuanceExplanation,
      };
}

/// Offline rule engine transforming and validating German Verb-First Conditionals
/// (Uneingeleitete Konditionalsätze / Spitzenstellung des finiten Verbs ohne "wenn").
/// Accurately shifts between formal V1 structures (Hätte er gewusst, ...) and standard wenn-clauses.
class GermanVerbFirstConditionalEngine {
  /// Convert standard "wenn"-conditional clause to elevated Verb-First (V1) structure.
  static VerbFirstConditionalStructure convertWennToVerbFirst({
    required String subject,
    required String finiteVerbK2, // e.g. "hätte", "wäre", "sollte"
    required String conditionRemainder, // e.g. "mehr Zeit gehabt", "es morgen regnen"
    required String consequenceMainVerb, // e.g. "wäre", "sagen"
    required String consequenceSubject,  // e.g. "ich", "wir"
    required String consequenceRemainder, // e.g. "gekommen", "das Treffen ab"
    bool useCorrelateSo = true,
  }) {
    final capVerbK2 = finiteVerbK2.trim()[0].toUpperCase() + finiteVerbK2.trim().substring(1);
    final sub = subject.trim();
    final rem = conditionRemainder.trim();

    // V1 Condition: Verb + Subject + Remainder (e.g. "Hätte ich mehr Zeit gehabt")
    final v1Condition = '$capVerbK2 $sub $rem'.replaceAll(RegExp(r'\s+'), ' ');

    // Standard Wenn Condition: "Wenn" + Subject + Remainder + Verb (e.g. "Wenn ich mehr Zeit gehabt hätte")
    final wennCondition = 'Wenn $sub $rem ${finiteVerbK2.trim()}'.replaceAll(RegExp(r'\s+'), ' ');

    // Consequence main clause: (so / dann) + Verb + Subject + Remainder
    final correlate = useCorrelateSo ? 'so ' : '';
    final mainClause = '$correlate${consequenceMainVerb.trim()} ${consequenceSubject.trim()} ${consequenceRemainder.trim()}'.replaceAll(RegExp(r'\s+'), ' ');

    final v1Sentence = '$v1Condition, $mainClause.';
    final wennSentence = '$wennCondition, $mainClause.';

    final arabic = 'أسلوب شرطي راقٍ بدون أداة (V1-Stellung): تصدّر الفعل المصرف بداية جملة الشرط مع حذف أداة الشرط (wenn)، مما يعطي النص فصاحة وجزالة أكاديمية.';

    return VerbFirstConditionalStructure(
      conditionVerbFirst: v1Condition,
      conditionWennClause: wennCondition,
      consequenceMainClause: mainClause,
      fullV1Sentence: v1Sentence,
      fullWennSentence: wennSentence,
      arabicNuanceExplanation: arabic,
    );
  }
}
