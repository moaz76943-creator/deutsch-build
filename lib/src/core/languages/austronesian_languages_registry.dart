import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class AustronesianLanguagesRegistry {
  static const LanguageProfile indonesianProfile = LanguageProfile(
    isoCode: 'id',
    autonym: 'Bahasa Indonesia',
    englishName: 'Indonesian',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Agglutinative',
    casesCount: 0,
    caseNames: [],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: false,
    hasVerbConjugation: false,
  );

  static const LanguageProfile tagalogProfile = LanguageProfile(
    isoCode: 'tl',
    autonym: 'Tagalog',
    englishName: 'Tagalog',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'VSO',
    morphologyType: 'Agglutinative',
    casesCount: 3,
    caseNames: ['Direct (Ang)', 'Indirect (Ng)', 'Oblique (Sa)'],
    genders: ['none'],
    hasArticles: true,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(indonesianProfile);
    engine.registerProfile(tagalogProfile);
  }
}
