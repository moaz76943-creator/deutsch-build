import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class EasternIndicLanguagesRegistry {
  static const LanguageProfile bengaliProfile = LanguageProfile(
    isoCode: 'bn',
    autonym: 'বাংলা',
    englishName: 'Bengali',
    scriptDirection: 'ltr',
    scriptFamily: 'Bengali',
    typology: 'SOV',
    morphologyType: 'Fusional',
    casesCount: 4,
    caseNames: ['Nominative', 'Objective', 'Genitive', 'Locative'],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile odiaProfile = LanguageProfile(
    isoCode: 'or',
    autonym: 'ଓଡ଼ିଆ',
    englishName: 'Odia',
    scriptDirection: 'ltr',
    scriptFamily: 'Odia',
    typology: 'SOV',
    morphologyType: 'Fusional',
    casesCount: 6,
    caseNames: ['Nominative', 'Accusative', 'Instrumental', 'Dative', 'Ablative', 'Genitive'],
    genders: ['m', 'f', 'n'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(bengaliProfile);
    engine.registerProfile(odiaProfile);
  }
}
