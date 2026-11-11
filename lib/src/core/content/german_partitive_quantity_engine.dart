/// Syntactic construction type for quantity and partitive expressions.
enum QuantityConstructionType {
  measureApposition,  // ein Glas Wasser / zwei Kilo Äpfel
  truePartitiveGenitive, // einer der Männer / ein Teil der Gruppe
  prepositionalVonDativ, // einer von den Studenten / ein Glas von dem Wein
}

/// Gender of the quantified target entity.
enum TargetEntityGender { masculine, feminine, neutral, plural }

/// Analysis descriptor of a constructed quantity / partitive phrase.
class QuantityPhraseStructure {
  final String quantityUnit;
  final String substanceOrGroup;
  final QuantityConstructionType type;
  final TargetEntityGender targetGender;
  final String generatedPhrase;
  final String arabicTranslation;

  QuantityPhraseStructure({
    required this.quantityUnit,
    required this.substanceOrGroup,
    required this.type,
    required this.targetGender,
    required this.generatedPhrase,
    required this.arabicTranslation,
  });

  Map<String, dynamic> toJson() => {
        'unit': quantityUnit,
        'target': substanceOrGroup,
        'type': type.name,
        'gender': targetGender.name,
        'phrase': generatedPhrase,
        'arabic': arabicTranslation,
      };
}

/// Offline rule engine constructing German measure expressions (Mengenangaben)
/// and Partitive Genitives (Partitiver Genitiv z.B. einer der Studenten, ein Teil der Bevölkerung).
class GermanPartitiveQuantityEngine {
  /// Build measure apposition (e.g. ein Glas kaltes Wasser / zwei Kilo Äpfel).
  static QuantityPhraseStructure buildMeasureApposition({
    required String quantityWord, // e.g. "ein Glas", "eine Tasse", "zwei Kilo"
    required String substance,    // e.g. "Wasser", "Kaffee", "Äpfel"
    String? modifierAdjective,    // e.g. "kalt", "heiß", "frisch"
    TargetEntityGender gender = TargetEntityGender.neutral,
    String arabic = '',
  }) {
    String adjPhrase = '';
    if (modifierAdjective != null && modifierAdjective.isNotEmpty) {
      // Strong neuter/masculine/feminine ending without article
      if (gender == TargetEntityGender.neutral) {
        adjPhrase = ' ${modifierAdjective}es';
      } else if (gender == TargetEntityGender.masculine) {
        adjPhrase = ' ${modifierAdjective}er';
      } else if (gender == TargetEntityGender.feminine) {
        adjPhrase = ' ${modifierAdjective}e';
      } else {
        adjPhrase = ' ${modifierAdjective}e';
      }
    }

    final phrase = '$quantityWord$adjPhrase $substance';

    return QuantityPhraseStructure(
      quantityUnit: quantityWord,
      substanceOrGroup: substance,
      type: QuantityConstructionType.measureApposition,
      targetGender: gender,
      generatedPhrase: phrase,
      arabicTranslation: arabic.isNotEmpty ? arabic : 'تعبير كمية ومقدار مع تمييز اسمي',
    );
  }

  /// Build true partitive genitive (e.g. "einer der Studenten", "eine der Frauen", "eines der Bücher").
  static QuantityPhraseStructure buildPartitiveGenitive({
    required TargetEntityGender gender,
    required String groupNounPlural, // e.g. "Studenten", "Frauen", "Kinder", "Freunde"
    String pronounSelector = 'ein', // e.g. "ein", "jeder", "kein"
    String arabic = '',
  }) {
    String selector = 'einer';
    String genitiveArticle = 'der';

    switch (gender) {
      case TargetEntityGender.masculine:
        selector = (pronounSelector == 'jeder') ? 'jeder' : 'einer';
        break;
      case TargetEntityGender.feminine:
        selector = (pronounSelector == 'jeder') ? 'jede' : 'eine';
        break;
      case TargetEntityGender.neutral:
        selector = (pronounSelector == 'jeder') ? 'jedes' : 'eines';
        break;
      case TargetEntityGender.plural:
        selector = 'viele';
        break;
    }

    final phrase = '$selector $genitiveArticle $groupNounPlural';

    return QuantityPhraseStructure(
      quantityUnit: selector,
      substanceOrGroup: groupNounPlural,
      type: QuantityConstructionType.truePartitiveGenitive,
      targetGender: gender,
      generatedPhrase: phrase,
      arabicTranslation: arabic.isNotEmpty ? arabic : 'مضاف إليه جزئي يفيد التبعيض (واحد من...)',
    );
  }
}
