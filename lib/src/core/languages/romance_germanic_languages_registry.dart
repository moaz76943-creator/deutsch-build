import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

/// Registry providing statically compiled and asset-driven Romance and Germanic language profiles.
class RomanceGermanicLanguagesRegistry {
  static const LanguageProfile italianProfile = LanguageProfile(
    isoCode: 'it',
    autonym: 'Italiano',
    englishName: 'Italian',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['m', 'f'],
    hasArticles: true,
    hasNounDeclension: false,
    hasVerbConjugation: true,
  );

  static const LanguageProfile portugueseProfile = LanguageProfile(
    isoCode: 'pt',
    autonym: 'Português',
    englishName: 'Portuguese',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['m', 'f'],
    hasArticles: true,
    hasNounDeclension: false,
    hasVerbConjugation: true,
  );

  static const LanguageProfile dutchProfile = LanguageProfile(
    isoCode: 'nl',
    autonym: 'Nederlands',
    englishName: 'Dutch',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['common', 'n'],
    hasArticles: true,
    hasNounDeclension: false,
    hasVerbConjugation: true,
  );

  /// Registers Italian, Portuguese, and Dutch into the global engine.
  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(italianProfile);
    engine.registerProfile(portugueseProfile);
    engine.registerProfile(dutchProfile);
  }
}
