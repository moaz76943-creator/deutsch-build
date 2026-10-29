import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class NordicLanguagesRegistry {
  static const LanguageProfile swedishProfile = LanguageProfile(
    isoCode: 'sv',
    autonym: 'Svenska',
    englishName: 'Swedish',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['common', 'n'],
    hasArticles: true,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile icelandicProfile = LanguageProfile(
    isoCode: 'is',
    autonym: 'Íslenska',
    englishName: 'Icelandic',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 4,
    caseNames: ['Nefnifall', 'Þolfall', 'Þágufall', 'Eignarfall'],
    genders: ['m', 'f', 'n'],
    hasArticles: true,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(swedishProfile);
    engine.registerProfile(icelandicProfile);
  }
}
