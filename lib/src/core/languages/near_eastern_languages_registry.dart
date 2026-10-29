import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

/// Registry providing statically compiled and asset-driven Near Eastern language profiles.
class NearEasternLanguagesRegistry {
  static const LanguageProfile turkishProfile = LanguageProfile(
    isoCode: 'tr',
    autonym: 'Türkçe',
    englishName: 'Turkish',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SOV',
    morphologyType: 'Agglutinative',
    casesCount: 6,
    caseNames: ['Yalın', 'Belirtme', 'Yönelme', 'Bulunma', 'Ayrılma', 'İlgi'],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile persianProfile = LanguageProfile(
    isoCode: 'fa',
    autonym: 'فارسی',
    englishName: 'Persian',
    scriptDirection: 'rtl',
    scriptFamily: 'Perso-Arabic',
    typology: 'SOV',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: false,
    hasVerbConjugation: true,
  );

  static const LanguageProfile urduProfile = LanguageProfile(
    isoCode: 'ur',
    autonym: 'اردو',
    englishName: 'Urdu',
    scriptDirection: 'rtl',
    scriptFamily: 'Perso-Arabic (Nastaliq)',
    typology: 'SOV',
    morphologyType: 'Fusional',
    casesCount: 3,
    caseNames: ['Direct', 'Oblique', 'Vocative'],
    genders: ['m', 'f'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  /// Registers Turkish, Persian, and Urdu into the global engine.
  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(turkishProfile);
    engine.registerProfile(persianProfile);
    engine.registerProfile(urduProfile);
  }
}
