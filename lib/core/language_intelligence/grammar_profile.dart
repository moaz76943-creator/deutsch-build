import 'grammar_capabilities.dart';
import 'language_grammar_rule_provider.dart'
    show GrammaticalGender, GrammaticalNumber, GrammaticalCase, MorphologyType;

class GrammarProfile {
  final String languageCode;
  final Set<GrammarCapability> capabilities;
  final Set<GrammarCapability> supportedFeatures;
  final Set<GrammaticalGender> supportedGenders;
  final Set<GrammaticalNumber> supportedNumbers;
  final Set<GrammaticalCase> supportedCases;
  final MorphologyType morphologyType;
  final bool supportsAgreement;

  const GrammarProfile({
    this.languageCode = '',
    this.capabilities = const {},
    this.supportedFeatures = const {},
    this.supportedGenders = const {},
    this.supportedNumbers = const {},
    this.supportedCases = const {},
    this.morphologyType = MorphologyType.unknown,
    this.supportsAgreement = false,
  });

  bool supports(GrammarCapability capability) => supportsFeature(capability);

  bool supportsFeature(GrammarCapability feature) {
    if (capabilities.contains(feature) || supportedFeatures.contains(feature)) {
      return true;
    }
    switch (feature) {
      case GrammarCapability.gender:
        return supportedGenders.isNotEmpty;
      case GrammarCapability.caseSystem:
      case GrammarCapability.nounClasses:
        return supportedCases.isNotEmpty ||
            capabilities.contains(GrammarCapability.caseSystem) ||
            capabilities.contains(GrammarCapability.nounClasses) ||
            supportedFeatures.contains(GrammarCapability.caseSystem) ||
            supportedFeatures.contains(GrammarCapability.nounClasses);
      case GrammarCapability.number:
        return supportedNumbers.isNotEmpty;
      case GrammarCapability.agreement:
        return supportsAgreement;
      case GrammarCapability.rootPattern:
        return morphologyType == MorphologyType.rootPattern;
      case GrammarCapability.inflectional:
        return morphologyType == MorphologyType.inflectional;
      case GrammarCapability.agglutinative:
        return morphologyType == MorphologyType.agglutinative;
      case GrammarCapability.analytic:
        return morphologyType == MorphologyType.analytic;
      default:
        return false;
    }
  }

  bool supportsNumber(GrammaticalNumber number) =>
      supportedNumbers.contains(number);
  bool supportsCase(GrammaticalCase grammaticalCase) =>
      supportedCases.contains(grammaticalCase);
}
