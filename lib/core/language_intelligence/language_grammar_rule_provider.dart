enum GrammaticalGender {
  masculine,
  feminine,
  neuter,
  common,
  none,
}

enum GrammaticalCategory {
  noun,
  verb,
  adjective,
  adverb,
  preposition,
  particle,
  unknown,
}

abstract class LanguageGrammarRuleProvider {
  String get languageCode;

  GrammarCapabilityProfile get profile => GrammarCapabilityProfile.empty();

  VerifiedGrammarEvidence getVerifiedEvidence(String word) =>
      VerifiedGrammarEvidence.unsupported();

  /// استنتاج الجنس النحوي للكلمة
  GrammaticalGender determineGender(String word, {String? article});

  /// استنتاج الفئة النحوية
  GrammaticalCategory determineCategory(String word, {String? article});

  /// التحقق مما إذا كانت الأداة مطابقة للكلمة
  bool isValidArticle(String word, String article);
}

enum GrammaticalNumber { singular, dual, plural, none }

enum GrammaticalCase { nominative, accusative, dative, genitive, instrumental, prepositional, vocative, none }

enum GrammaticalTense { past, present, future, none }

enum GrammaticalAspect { perfective, imperfective, continuous, none }

enum GrammaticalMood { indicative, subjunctive, imperative, conditional, none }

enum GrammaticalPerson { first, second, third, none }

enum MorphologyType { rootPattern, agglutinative, inflectional, analytic, unknown }

class NounClass {
  final String identifier;
  final String localizedLabel;
  const NounClass(this.identifier, this.localizedLabel);
}

class GrammarCapabilityProfile {
  final Set<GrammaticalGender> supportedGenders;
  final Set<GrammaticalCase> supportedCases;
  final Set<GrammaticalNumber> supportedNumbers;
  final Set<NounClass> supportedNounClasses;
  final MorphologyType morphologyType;
  final bool supportsAgreement;

  const GrammarCapabilityProfile({
    this.supportedGenders = const {},
    this.supportedCases = const {},
    this.supportedNumbers = const {},
    this.supportedNounClasses = const {},
    this.morphologyType = MorphologyType.unknown,
    this.supportsAgreement = false,
  });

  factory GrammarCapabilityProfile.empty() => const GrammarCapabilityProfile();
}

class VerifiedGrammarEvidence {
  final bool isSupported;
  final String? root;
  final String? pattern;
  final List<String> agglutinativeChains;
  final GrammaticalTense tense;
  final GrammaticalAspect aspect;
  final GrammaticalMood mood;
  final GrammaticalPerson person;

  const VerifiedGrammarEvidence({
    required this.isSupported,
    this.root,
    this.pattern,
    this.agglutinativeChains = const [],
    this.tense = GrammaticalTense.none,
    this.aspect = GrammaticalAspect.none,
    this.mood = GrammaticalMood.none,
    this.person = GrammaticalPerson.none,
  });

  factory VerifiedGrammarEvidence.unsupported() => const VerifiedGrammarEvidence(isSupported: false);
}
