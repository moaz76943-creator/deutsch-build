import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class CelticLanguagesRegistry {
  static const LanguageProfile irishProfile = LanguageProfile(
    isoCode: 'ga',
    autonym: 'Gaeilge',
    englishName: 'Irish',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'VSO',
    morphologyType: 'Fusional',
    casesCount: 4,
    caseNames: ['Ainmneach', 'Gairmeach', 'Ginideach', 'Tabharthach'],
    genders: ['m', 'f'],
    hasArticles: true,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile welshProfile = LanguageProfile(
    isoCode: 'cy',
    autonym: 'Cymraeg',
    englishName: 'Welsh',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'VSO',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['m', 'f'],
    hasArticles: true,
    hasNounDeclension: false,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(irishProfile);
    engine.registerProfile(welshProfile);
  }
}
