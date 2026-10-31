class LanguageProfile {
  final String code; // مثل: 'de', 'es', 'fr', 'en', 'it', 'tr', 'ru'
  final String nameEn;
  final String nameAr;
  final bool hasGenders;
  final List<String> articles;

  const LanguageProfile({
    required this.code,
    required this.nameEn,
    required this.nameAr,
    this.hasGenders = false,
    this.articles = const [],
  });
}

class LanguageRegistry {
  static const Map<String, LanguageProfile> supportedLanguages = {
    'de': LanguageProfile(
        code: 'de',
        nameEn: 'German',
        nameAr: 'الألمانية',
        hasGenders: true,
        articles: ['der', 'die', 'das']),
    'en': LanguageProfile(
        code: 'en',
        nameEn: 'English',
        nameAr: 'الإنجليزية',
        hasGenders: false,
        articles: ['the', 'a', 'an']),
    'fr': LanguageProfile(
        code: 'fr',
        nameEn: 'French',
        nameAr: 'الفرنسية',
        hasGenders: true,
        articles: ['le', 'la', 'les', "l'"]),
    'es': LanguageProfile(
        code: 'es',
        nameEn: 'Spanish',
        nameAr: 'الإسبانية',
        hasGenders: true,
        articles: ['el', 'la', 'los', 'las']),
    'it': LanguageProfile(
        code: 'it',
        nameEn: 'Italian',
        nameAr: 'الإيطالية',
        hasGenders: true,
        articles: ['il', 'lo', 'la', 'i', 'gli', 'le']),
    'tr': LanguageProfile(
        code: 'tr', nameEn: 'Turkish', nameAr: 'التركية', hasGenders: false),
    'ru': LanguageProfile(
        code: 'ru', nameEn: 'Russian', nameAr: 'الروسية', hasGenders: true),
    'ar': LanguageProfile(
        code: 'ar', nameEn: 'Arabic', nameAr: 'العربية', hasGenders: true),
  };

  static LanguageProfile getProfile(String code) {
    return supportedLanguages[code.toLowerCase()] ??
        LanguageProfile(
          code: code,
          nameEn: 'Universal',
          nameAr: 'لغة عالمية',
        );
  }
}
