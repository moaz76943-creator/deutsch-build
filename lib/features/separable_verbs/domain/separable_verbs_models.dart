enum PrefixType {
  separable,
  inseparable,
  dualVariable,
}

enum PrefixPlacement {
  position2Attached,
  sentenceEndDetached,
}

final class VerbPrefixDrillItem {
  VerbPrefixDrillItem({
    required this.id,
    required this.fullInfinitive,
    required this.prefix,
    required this.rootVerb,
    required this.prefixType,
    required this.ruleExplanation,
    required this.expectedPlacement,
    required this.trainingSentenceTemplate,
    required this.completedSentence,
    required this.arabicTranslation,
    required this.meaningExplanationAr,
    required this.subjectPronoun,
    required this.expectedConjugatedVerb,
    required List<String> conjugationChoices,
  })  : assert(id.length > 0),
        assert(fullInfinitive.length > 0),
        assert(prefix.length > 0),
        assert(rootVerb.length > 0),
        assert(conjugationChoices.length >= 2),
        conjugationChoices = List<String>.unmodifiable(conjugationChoices);

  final String id;
  final String fullInfinitive;
  final String prefix;
  final String rootVerb;
  final PrefixType prefixType;
  final String ruleExplanation;
  final PrefixPlacement expectedPlacement;
  final String trainingSentenceTemplate;
  final String completedSentence;
  final String arabicTranslation;
  final String meaningExplanationAr;
  final String subjectPronoun;
  final String expectedConjugatedVerb;
  final List<String> conjugationChoices;

  bool get separatesInThisMeaning =>
      expectedPlacement == PrefixPlacement.sentenceEndDetached;

  String get placementLabel => switch (expectedPlacement) {
        PrefixPlacement.position2Attached => 'Position 2 · السابقة متصلة',
        PrefixPlacement.sentenceEndDetached => 'Satzende · السابقة منفصلة',
      };
}
