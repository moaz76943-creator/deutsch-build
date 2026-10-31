import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class BalticLanguagesRegistry {
  static const LanguageProfile lithuanianProfile = LanguageProfile(
    isoCode: 'lt',
    autonym: 'Lietuvių',
    englishName: 'Lithuanian',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 7,
    caseNames: ['Vardininkas', 'Kilmininkas', 'Naudininkas', 'Galininkas', 'Įnagininkas', 'Vietininkas', 'Šauksmininkas'],
    genders: ['m', 'f'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile estonianProfile = LanguageProfile(
    isoCode: 'et',
    autonym: 'Eesti',
    englishName: 'Estonian',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Agglutinative',
    casesCount: 14,
    caseNames: ['Nimetav', 'Omastav', 'Osastav', 'Sisseütlev', 'Seesütlev', 'Seestütlev', 'Alaleütlev', 'Alalütlev', 'Alaltütlev', 'Saav', 'Rajav', 'Olev', 'Ilmaütlev', 'Kaasaütlev'],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(lithuanianProfile);
    engine.registerProfile(estonianProfile);
  }
}
