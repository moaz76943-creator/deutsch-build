import 'hundred_languages_registry.dart';

class GrammarRuleModel {
  const GrammarRuleModel({
    required this.ruleName,
    required this.description,
    required this.examples,
  });

  final String ruleName;
  final String description;
  final List<String> examples;

  Map<String, dynamic> toJson() => {
        'ruleName': ruleName,
        'description': description,
        'examples': examples,
      };
}

class AdvancedGrammarEngine {
  static List<GrammarRuleModel> getRulesForLanguage(String languageCode) {
    final language = HundredLanguagesRegistry.getLanguage(languageCode);
    
    if (language.hasGenderCases) {
      return [
        const GrammarRuleModel(
          ruleName: 'Gender and Cases',
          description: 'This language incorporates grammatical gender and case declensions.',
          examples: ['Nominative', 'Accusative', 'Dative'],
        ),
      ];
    } else {
      return [
        const GrammarRuleModel(
          ruleName: 'Standard Structure',
          description: 'Direct structural flow without complex noun case declensions.',
          examples: ['Subject-Verb-Object'],
        ),
      ];
    }
  }
}
