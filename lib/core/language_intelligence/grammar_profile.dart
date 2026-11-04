import 'grammar_capabilities.dart';
import 'language_grammar_rule_provider.dart';

class GrammarProfile {
  final String languageCode;
  final Set<GrammarFeature> supportedFeatures;
  final Set<GrammarFeature> capabilities;
  final Set<GrammaticalGender> supportedGenders;
  final Set<GrammaticalNumber> supportedNumbers;
  final Set<GrammaticalCase> supportedCases;
  final MorphologyType morphologyType;
  final bool supportsAgreement;

  const GrammarProfile({
    this.languageCode = '',
    this.supportedFeatures = const {},
    this.capabilities = const {},
    this.supportedGenders = const {},
    this.supportedNumbers = const {},
    this.supportedCases = const {},
    this.morphologyType = MorphologyType.unknown,
    this.supportsAgreement = false,
  });

  bool supportsFeature(GrammarFeature feature) =>
      supportedFeatures.contains(feature) || capabilities.contains(feature);

  bool supports(GrammarFeature capability) => supportsFeature(capability);

  bool supportsNumber(GrammaticalNumber number) => supportedNumbers.contains(number);
  bool supportsCase(GrammaticalCase grammaticalCase) => supportedCases.contains(grammaticalCase);
}

class GrammarCapabilityProfile extends GrammarProfile {
  final bool hasGender;
  final bool hasCases;
  final bool hasNumber;
  final bool hasPerson;
  final bool hasTense;
  final bool hasAspect;
  final bool hasMood;
  final bool hasRootPatternMorphology;
  final bool isAgglutinative;
  final bool isAnalytic;
  final bool hasNounClasses;

  const GrammarCapabilityProfile({
    this.hasGender = false,
    this.hasCases = false,
    this.hasNumber = false,
    this.hasPerson = false,
    this.hasTense = false,
    this.hasAspect = false,
    this.hasMood = false,
    this.hasRootPatternMorphology = false,
    this.isAgglutinative = false,
    this.isAnalytic = false,
    this.hasNounClasses = false,
    super.supportedGenders = const {},
    super.supportedNumbers = const {},
    super.supportedCases = const {},
    super.morphologyType = MorphologyType.unknown,
    super.supportsAgreement = false,
  }) : super(
         supportedFeatures: const {},
       );

  @override
  bool supportsFeature(GrammarFeature feature) {
    switch (feature) {
      case GrammarFeature.gender: return hasGender;
      case GrammarFeature.grammaticalCase:
      case GrammarFeature.caseSystem: return hasCases;
      case GrammarFeature.number: return hasNumber;
      case GrammarFeature.person: return hasPerson;
      case GrammarFeature.tense: return hasTense;
      case GrammarFeature.aspect: return hasAspect;
      case GrammarFeature.mood: return hasMood;
      case GrammarFeature.rootPattern: return hasRootPatternMorphology;
      case GrammarFeature.agglutinative: return isAgglutinative;
      case GrammarFeature.analytic: return isAnalytic;
      case GrammarFeature.nounClasses: return hasNounClasses;
      default: return super.supportsFeature(feature);
    }
  }
}
