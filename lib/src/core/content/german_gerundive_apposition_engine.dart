/// Underlying modal sense of the Gerundive (Modalpartizip).
enum GerundiveModalSense { obligationMuss, possibilityKann, prohibitionDarfNicht }

/// Analysis descriptor of an engineered Gerundive structure.
class GerundiveStructureResult {
  final String noun;
  final String verbInfinitive;
  final GerundiveModalSense modalSense;
  final String gerundivePhrase; // e.g. "das zu lösende Problem"
  final String equivalentRelativeClause; // e.g. "das Problem, das gelöst werden muss"
  final String arabicEquivalence;

  GerundiveStructureResult({
    required this.noun,
    required this.verbInfinitive,
    required this.modalSense,
    required this.gerundivePhrase,
    required this.equivalentRelativeClause,
    required this.arabicEquivalence,
  });

  Map<String, dynamic> toJson() => {
        'noun': noun,
        'verb': verbInfinitive,
        'modal': modalSense.name,
        'gerundive': gerundivePhrase,
        'relative_clause': equivalentRelativeClause,
        'arabic': arabicEquivalence,
      };
}

/// Offline rule engine constructing and decomposing German Gerundive phrases (Gerundiv / Modalpartizip: zu + Partizip I + Endung).
/// Converts high-register attributive contractions into clear relative clauses with passive modals (müssen/können + Passiv).
class GermanGerundiveAppositionEngine {
  /// Build Gerundive phrase and its relative passive equivalent.
  static GerundiveStructureResult buildGerundive({
    required String article,
    required String noun,
    required String verbInfinitive,
    required String partizipTwo,
    String adjectiveEnding = 'e',
    GerundiveModalSense modalSense = GerundiveModalSense.obligationMuss,
  }) {
    final cleanVerb = verbInfinitive.trim().toLowerCase();
    final cleanNoun = noun.trim();

    // Gerundive: "zu" + verb stem + "d" + adjective ending
    // e.g. lösen -> zu lösend-e
    final gerundiveForm = 'zu ${cleanVerb}d$adjectiveEnding';
    final gerundivePhrase = '$article $gerundiveForm $cleanNoun'.replaceAll(RegExp(r'\s+'), ' ');

    String modalVerb = 'muss';
    if (modalSense == GerundiveModalSense.possibilityKann) {
      modalVerb = 'kann';
    } else if (modalSense == GerundiveModalSense.prohibitionDarfNicht) {
      modalVerb = 'nicht darf';
    }

    final relArticle = article.toLowerCase() == 'das' ? 'das' : (article.toLowerCase() == 'die' ? 'die' : 'der');
    final relativeClause = '$article $cleanNoun, $relArticle $partizipTwo werden $modalVerb';

    final arabic = (modalSense == GerundiveModalSense.obligationMuss)
        ? 'صيغة جيرونديف (Gerundiv) تفيد حتمية ووجوب الفعل بصيغة المبني للمجهول'
        : 'صيغة جيرونديف تفيد قابلية وإمكانية الفعل بصيغة المبني للمجهول';

    return GerundiveStructureResult(
      noun: cleanNoun,
      verbInfinitive: cleanVerb,
      modalSense: modalSense,
      gerundivePhrase: gerundivePhrase,
      equivalentRelativeClause: relativeClause,
      arabicEquivalence: arabic,
    );
  }
}
