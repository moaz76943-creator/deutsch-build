import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class DravidianLanguagesRegistry {
  static const LanguageProfile tamilProfile = LanguageProfile(
    isoCode: 'ta',
    autonym: 'தமிழ்',
    englishName: 'Tamil',
    scriptDirection: 'ltr',
    scriptFamily: 'Tamil',
    typology: 'SOV',
    morphologyType: 'Agglutinative',
    casesCount: 8,
    caseNames: ['Ezhuvay', 'Seyappaduporul', 'Karuvi', 'Udannegazhchi', 'Kodai', 'Neengal', 'Udamai', 'Idam'],
    genders: ['m', 'f', 'n'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile malayalamProfile = LanguageProfile(
    isoCode: 'ml',
    autonym: 'മലയാളം',
    englishName: 'Malayalam',
    scriptDirection: 'ltr',
    scriptFamily: 'Malayalam',
    typology: 'SOV',
    morphologyType: 'Agglutinative',
    casesCount: 7,
    caseNames: ['Nirdeshika', 'Prathigrahika', 'Samyojika', 'Uddeshika', 'Prayojika', 'Sambandhika', 'Aadharika'],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(tamilProfile);
    engine.registerProfile(malayalamProfile);
  }
}
