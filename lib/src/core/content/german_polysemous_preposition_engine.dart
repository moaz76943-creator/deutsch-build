/// Semantic domain of the prepositional transfer.
enum PrepositionalSemanticDomain {
  spatialConcrete,      // مكان مادي مباشر
  temporalConcrete,     // زمان مادي محدد
  abstractCauseMotive,  // دافع داخلي واعٍ (aus)
  abstractInvoluntary,  // انفعال لاإرادي حتمي (vor)
  mannerMethod,         // كيفية وطريقة (auf diese Weise, auf Deutsch)
  quantitativeApproximation, // تقريب عددي (an die 100)
  stateCondition,       // حالة معنوية (in Gefahr, in Eile)
}

/// Analysis descriptor of an identified polysemous prepositional nuance.
class PolysemousPrepositionEntry {
  final String preposition;
  final String contextNounPhrase;
  final PrepositionalSemanticDomain domain;
  final String sampleSentence;
  final String arabicNuanceExplanation;

  const PolysemousPrepositionEntry({
    required this.preposition,
    required this.contextNounPhrase,
    required this.domain,
    required this.sampleSentence,
    required this.arabicNuanceExplanation,
  });

  Map<String, dynamic> toJson() => {
        'prep': preposition,
        'phrase': contextNounPhrase,
        'domain': domain.name,
        'sentence': sampleSentence,
        'arabic': arabicNuanceExplanation,
      };
}

/// Offline rule engine resolving German Polysemous Prepositions (an, auf, in, aus, vor)
/// in abstract and metaphorical extensions.
/// Differentiates conscious internal motives (aus Liebe) from involuntary physical reactions (vor Angst zittern).
class GermanPolysemousPrepositionEngine {
  static const List<PolysemousPrepositionEntry> _registry = [
    // aus vs. vor: Conscious Motive vs. Involuntary Reaction
    PolysemousPrepositionEntry(
      preposition: 'aus',
      contextNounPhrase: 'aus Mitleid / aus Liebe / aus Höflichkeit',
      domain: PrepositionalSemanticDomain.abstractCauseMotive,
      sampleSentence: 'Er handelte aus reiner Höflichkeit.',
      arabicNuanceExplanation: 'استخدام (aus): يفيد الدافع الباطني الإرادي الواعي الذي ينبع من داخل الإنسان',
    ),
    PolysemousPrepositionEntry(
      preposition: 'vor',
      contextNounPhrase: 'vor Kälte / vor Angst / vor Freude',
      domain: PrepositionalSemanticDomain.abstractInvoluntary,
      sampleSentence: 'Sie zitterte vor Kälte und weinte vor Freude.',
      arabicNuanceExplanation: 'استخدام (vor): يفيد ردة الفعل اللاإرادية الحتمية الناتجة عن قوة خارجية أو شعور قاهر',
    ),
    // an: Quantitative & Qualitative Deficiency/Abundance
    PolysemousPrepositionEntry(
      preposition: 'an',
      contextNounPhrase: 'an die 50 Personen / reich an Vitaminen',
      domain: PrepositionalSemanticDomain.quantitativeApproximation,
      sampleSentence: 'An der Konferenz nahmen an die zweihundert Experten teil.',
      arabicNuanceExplanation: 'استخدام (an): يفيد التقريب العددي (ما يقارب / زهاء) أو تحديد مجال الوفرة والنقصان',
    ),
    // auf: Manner & Cost
    PolysemousPrepositionEntry(
      preposition: 'auf',
      contextNounPhrase: 'auf Deutsch / auf eigene Kosten',
      domain: PrepositionalSemanticDomain.mannerMethod,
      sampleSentence: 'Wir führen die gesamte Diskussion auf Deutsch.',
      arabicNuanceExplanation: 'استخدام (auf): يفيد الكيفية والأسلوب أو التحمل المالي والتكلفة',
    ),
    // in: State & Condition
    PolysemousPrepositionEntry(
      preposition: 'in',
      contextNounPhrase: 'in Gefahr / in Eile / in Ruhe',
      domain: PrepositionalSemanticDomain.stateCondition,
      sampleSentence: 'Bitte prüfen Sie das Dokument in aller Ruhe.',
      arabicNuanceExplanation: 'استخدام (in): يفيد الظرفية المعنوية والحالة الشعورية أو الإجرائية المحيطة',
    ),
  ];

  /// Disambiguate whether "aus" or "vor" is required for an emotional/physiological noun.
  static String disambiguateAusVsVor(String emotionNoun) {
    final clean = emotionNoun.trim().toLowerCase();

    // Involuntary physical reactions -> vor
    const involuntary = {'angst', 'kaelte', 'kälte', 'schmerz', 'freude', 'schreck', 'wut'};
    if (involuntary.contains(clean)) {
      return 'vor';
    }

    // Conscious motives -> aus
    const conscious = {'liebe', 'mitleid', 'hoeflichkeit', 'höflichkeit', 'neid', 'stolz', 'interesse'};
    if (conscious.contains(clean)) {
      return 'aus';
    }

    return 'aus'; // Default intentional motive
  }

  /// Query all semantic nuances of a specific preposition.
  static List<PolysemousPrepositionEntry> getNuances(String prep) {
    final clean = prep.trim().toLowerCase();
    return _registry.where((e) => e.preposition == clean).toList();
  }
}
