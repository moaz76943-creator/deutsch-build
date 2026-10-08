class LanguageDefinition {
  const LanguageDefinition({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.family,
    this.hasGenderCases = false,
    this.hasComplexVerbConjugation = true,
  });

  final String code;
  final String name;
  final String nativeName;
  final String family;
  final bool hasGenderCases;
  final bool hasComplexVerbConjugation;

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'nativeName': nativeName,
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
      nativeName: 'Deutsch',
      family: 'Germanic',
      hasGenderCases: true,
    ),
    const LanguageDefinition(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      family: 'Semitic',
      hasGenderCases: true,
    ),
    const LanguageDefinition(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      family: 'Germanic',
      hasGenderCases: false,
    ),
    const LanguageDefinition(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      family: 'Romance',
      hasGenderCases: true,
    ),
    const LanguageDefinition(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
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
