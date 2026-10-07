import 'language_intelligence_contract.dart';

class AdvancedVerbConjugator {
  static List<VerbConjugationRule> getConjugationsForLanguage(String languageCode) {
    return LanguageIntelligenceContract.getStandardConjugations(languageCode);
  }

  static String conjugate(String verb, String tense, String pronoun, String languageCode) {
    final rules = getConjugationsForLanguage(languageCode);
    final rule = rules.firstWhere(
      (r) => r.tense == tense,
      orElse: () => const VerbConjugationRule(tense: '', pronounSuffixes: {}),
    );

    final suffix = rule.pronounSuffixes[pronoun] ?? '';
    return '$verb$suffix';
  }
}
