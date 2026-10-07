class LanguageDefinition {
  const LanguageDefinition({
    required this.code,
    required this.name,
    required this.family,
    this.hasGenderCases = false,
    this.hasComplexVerbConjugation = true,
  });

  final String code;
  final String name;
  final String family;
  final bool hasGenderCases;
  final bool hasComplexVerbConjugation;

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'family': family,
        'hasGenderCases': hasGenderCases,
        'hasComplexVerbConjugation': hasComplexVerbConjugation,
      };
}

class HundredLanguagesRegistry {
  static final List<LanguageDefinition> supportedLanguages = [
    const LanguageDefinition(
      code: 'de',
      name: 'German',
      family: 'Germanic',
      hasGenderCases: true,
    ),
    const LanguageDefinition(
      code: 'ar',
      name: 'Arabic',
      family: 'Semitic',
      hasGenderCases: true,
    ),
    const LanguageDefinition(
      code: 'en',
      name: 'English',
      family: 'Germanic',
      hasGenderCases: false,
    ),
    const LanguageDefinition(
      code: 'fr',
      name: 'French',
      family: 'Romance',
      hasGenderCases: true,
    ),
    const LanguageDefinition(
      code: 'es',
      name: 'Spanish',
      family: 'Romance',
      hasGenderCases: true,
    ),
  ];

  static LanguageDefinition getLanguage(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}
