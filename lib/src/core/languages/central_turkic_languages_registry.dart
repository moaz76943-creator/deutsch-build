import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class CentralTurkicLanguagesRegistry {
  static const LanguageProfile uzbekProfile = LanguageProfile(
    isoCode: 'uz',
    autonym: 'Oʻzbekcha',
    englishName: 'Uzbek',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SOV',
    morphologyType: 'Agglutinative',
    casesCount: 6,
    caseNames: ['Bosh', 'Qaratqich', 'Tushum', 'Joʻnalish', 'Oʻrin-payt', 'Chiqish'],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile azerbaijaniProfile = LanguageProfile(
    isoCode: 'az',
    autonym: 'Azərbaycanca',
    englishName: 'Azerbaijani',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SOV',
    morphologyType: 'Agglutinative',
    casesCount: 6,
    caseNames: ['Adlıq', 'Yiyəlik', 'Yönlük', 'Təsirlik', 'Yerlik', 'Çıxışlıq'],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(uzbekProfile);
    engine.registerProfile(azerbaijaniProfile);
  }
}
