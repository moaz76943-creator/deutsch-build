import 'grammar_capabilities.dart';
import 'language_grammar_rule_provider.dart'
    show GrammaticalGender, GrammaticalNumber, GrammaticalCase, MorphologyType;

class GrammarProfile {
  final String languageCode;
  final Set<GrammarFeature> capabilities;
  final Set<GrammarFeature> supportedFeatures;
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

  bool supports(GrammarFeature feature) => supportsFeature(feature);

  bool supportsFeature(GrammarFeature feature) {
    if (capabilities.contains(feature) || supportedFeatures.contains(feature)) {
      return true;
    }
    switch (feature) {
      case GrammarFeature.gender:
        return supportedGenders.isNotEmpty;
      case GrammarFeature.caseSystem:
      case GrammarFeature.grammaticalCase:
        return supportedCases.isNotEmpty ||
            capabilities.contains(GrammarFeature.caseSystem) ||
            capabilities.contains(GrammarFeature.grammaticalCase) ||
            supportedFeatures.contains(GrammarFeature.caseSystem) ||
            supportedFeatures.contains(GrammarFeature.grammaticalCase);
      case GrammarFeature.number:
        return supportedNumbers.isNotEmpty;
      case GrammarFeature.agreement:
        return supportsAgreement;
      case GrammarFeature.rootPattern:
        return morphologyType == MorphologyType.rootPattern;
      case GrammarFeature.inflectional:
        return morphologyType == MorphologyType.inflectional;
      case GrammarFeature.agglutinative:
        return morphologyType == MorphologyType.agglutinative;
      case GrammarFeature.analytic:
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
