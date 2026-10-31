import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class AfricanLanguagesRegistry {
  static const LanguageProfile swahiliProfile = LanguageProfile(
    isoCode: 'sw',
    autonym: 'Kiswahili',
    englishName: 'Swahili',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Agglutinative',
    casesCount: 0,
    caseNames: [],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile amharicProfile = LanguageProfile(
    isoCode: 'am',
    autonym: 'አማርኛ',
    englishName: 'Amharic',
    scriptDirection: 'ltr',
    scriptFamily: "Ge'ez (Ethiopic)",
    typology: 'SOV',
    morphologyType: 'Fusional',
    casesCount: 2,
    caseNames: ['Nominative', 'Accusative'],
    genders: ['m', 'f'],
    hasArticles: true,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(swahiliProfile);
    engine.registerProfile(amharicProfile);
  }
}
