import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class CaucasianLanguagesRegistry {
  static const LanguageProfile georgianProfile = LanguageProfile(
    isoCode: 'ka',
    autonym: 'ქართული',
    englishName: 'Georgian',
    scriptDirection: 'ltr',
    scriptFamily: 'Georgian (Mkhedruli)',
    typology: 'SOV',
    morphologyType: 'Agglutinative',
    casesCount: 7,
    caseNames: ['Nominative', 'Ergative', 'Dative', 'Genitive', 'Instrumental', 'Adverbial', 'Vocative'],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile armenianProfile = LanguageProfile(
    isoCode: 'hy',
    autonym: 'Հայերեն',
    englishName: 'Armenian',
    scriptDirection: 'ltr',
    scriptFamily: 'Armenian',
    typology: 'SOV',
    morphologyType: 'Fusional',
    casesCount: 7,
    caseNames: ['Nominative', 'Accusative', 'Genitive', 'Dative', 'Ablative', 'Instrumental', 'Locative'],
    genders: ['none'],
    hasArticles: true,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(georgianProfile);
    engine.registerProfile(armenianProfile);
  }
}
