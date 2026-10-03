enum GenitivDrillType {
  possessionArticle,
  genitivPrepositions,
}

enum GenitivGender {
  maskulin,
  neutrum,
  feminin,
  plural,
}

final class GenitivChallengeItem {
  const GenitivChallengeItem({
    required this.id,
    required this.type,
    required this.sentenceContext,
    required this.targetNoun,
    required this.gender,
    required this.correctArticle,
    required this.correctNounSuffix,
    required this.suffixReasonAr,
    required this.arabicTranslation,
    required this.explanationAr,
    this.genitivPreposition,
  })  : assert(id.length > 0),
        assert(sentenceContext.length > 0),
        assert(targetNoun.length > 0),
        assert(correctArticle == 'des' || correctArticle == 'der'),
        assert(
          correctNounSuffix == '' ||
              correctNounSuffix == 's' ||
              correctNounSuffix == 'es',
        ),
        assert(suffixReasonAr.length > 0),
        assert(arabicTranslation.length > 0),
        assert(explanationAr.length > 0),
        assert(
          type != GenitivDrillType.genitivPrepositions ||
              genitivPreposition != null,
        );

  final String id;
  final GenitivDrillType type;
  final String sentenceContext;
  final String targetNoun;
  final GenitivGender gender;
  final String correctArticle;
  final String correctNounSuffix;
  final String suffixReasonAr;
  final String? genitivPreposition;
  final String arabicTranslation;
  final String explanationAr;

  String get inflectedNoun => '$targetNoun$correctNounSuffix';

  bool get takesNounEnding =>
      gender == GenitivGender.maskulin ||
      gender == GenitivGender.neutrum;

  String get genderLabelDe => switch (gender) {
        GenitivGender.maskulin => 'Maskulin',
        GenitivGender.neutrum => 'Neutrum',
        GenitivGender.feminin => 'Feminin',
        GenitivGender.plural => 'Plural',
      };
}
