/// Type of comparative relationship.
enum ComparisonType {
  equalityWie,              // so / genauso ... wie
  inequalityAls,            // Komparativ ... als
  hypotheticalAlsObEndVerb, // als ob ... Verb am Ende (KII)
  hypotheticalAlsInversion, // als + Verb (KII) auf Position 2
}

/// Analysis descriptor of a constructed comparison sentence.
class ComparisonSentenceStructure {
  final ComparisonType type;
  final String matrixClause;
  final String comparativeParticle; // "wie", "als", "als ob", "als"
  final String comparativeClauseOrElement;
  final String fullSentence;
  final String arabicExplanation;

  ComparisonSentenceStructure({
    required this.type,
    required this.matrixClause,
    required this.comparativeParticle,
    required this.comparativeClauseOrElement,
    required this.fullSentence,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'matrix': matrixClause,
        'particle': comparativeParticle,
        'element': comparativeClauseOrElement,
        'sentence': fullSentence,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine constructing and validating German comparison clauses (Vergleichssätze).
/// Accurately differentiates "wie" (equality) from "als" (inequality),
/// and structures hypothetical comparisons ("als ob" + Verbletzt vs. "als" + Inversion).
class GermanComparisonClauseEngine {
  /// Build standard real comparison (equality or inequality).
  static ComparisonSentenceStructure buildRealComparison({
    required String subjectA,
    required String verb,
    required String adjectiveOrAdverb,
    required String entityB,
    bool isEquality = true,
  }) {
    final cleanSubj = subjectA.trim();
    final cleanVerb = verb.trim();
    final cleanAdj = adjectiveOrAdverb.trim();
    final cleanB = entityB.trim();

    String particle = '';
    String sentence = '';
    String arabic = '';

    if (isEquality) {
      particle = 'wie';
      sentence = '$cleanSubj $cleanVerb genauso $cleanAdj $particle $cleanB.';
      arabic = 'مقارنة تماثل وتطابق باستخدام (genauso ... wie)';
    } else {
      particle = 'als';
      sentence = '$cleanSubj $cleanVerb $cleanAdj $particle $cleanB.';
      arabic = 'مقارنة تفاوت وتفضيل باستخدام صيغة المقارنة + (als)';
    }

    return ComparisonSentenceStructure(
      type: isEquality ? ComparisonType.equalityWie : ComparisonType.inequalityAls,
      matrixClause: '$cleanSubj $cleanVerb $cleanAdj',
      comparativeParticle: particle,
      comparativeClauseOrElement: cleanB,
      fullSentence: sentence,
      arabicExplanation: arabic,
    );
  }

  /// Build hypothetical comparison (irrealer Vergleichssatz mit Konjunktiv II).
  /// Option A: als ob + Subject + Remainder + KII-Verb (Verb am Ende).
  /// Option B: als + KII-Verb + Subject + Remainder (Inversion).
  static ComparisonSentenceStructure buildHypotheticalComparison({
    required String matrixClause, // e.g. "Er tut so"
    required String subject,      // e.g. "er"
    required String k2Verb,       // e.g. "wüsste", "wäre", "hätte"
    required String remainder,    // e.g. "alles", "reich", "keine Zeit"
    bool useAlsOb = true,
  }) {
    final cleanMatrix = matrixClause.trim().replaceAll(RegExp(r'[,.!?]$'), '');
    final cleanSubj = subject.trim();
    final cleanVerb = k2Verb.trim();
    final cleanRem = remainder.trim();

    String sentence = '';
    String particle = '';
    ComparisonType type;

    if (useAlsOb) {
      // als ob + Subjekt + ... + Verb am Ende
      particle = 'als ob';
      type = ComparisonType.hypotheticalAlsObEndVerb;
      final subClause = '$cleanSubj $cleanRem $cleanVerb'.replaceAll(RegExp(r'\s+'), ' ');
      sentence = '$cleanMatrix, $particle $subClause.';
    } else {
      // als + Verb + Subjekt + ... (Inversion)
      particle = 'als';
      type = ComparisonType.hypotheticalAlsInversion;
      final subClause = '$cleanVerb $cleanSubj $cleanRem'.replaceAll(RegExp(r'\s+'), ' ');
      sentence = '$cleanMatrix, $particle $subClause.';
    }

    return ComparisonSentenceStructure(
      type: type,
      matrixClause: cleanMatrix,
      comparativeParticle: particle,
      comparativeClauseOrElement: '$cleanSubj $cleanRem $cleanVerb',
      fullSentence: sentence,
      arabicExplanation: 'مقارنة افتراضية غير واقعية تفيد التظاهر والتشبيه (وكأنه...)',
    );
  }
}
