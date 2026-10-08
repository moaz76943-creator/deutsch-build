import 'hundred_languages_registry.dart';
import 'language_intelligence_contract.dart';

class PackCompiler {
  static Map<String, dynamic> compileLanguagePack(String languageCode) {
    final language = HundredLanguagesRegistry.getLanguage(languageCode);
    final conjugations = LanguageIntelligenceContract.getStandardConjugations(languageCode);

    return {
      'metadata': language.toJson(),
      'conjugations': conjugations.map((rule) => rule.toJson()).toList(),
      'compiledAt': DateTime.now().toIso8601String(),
    };
  }
}
