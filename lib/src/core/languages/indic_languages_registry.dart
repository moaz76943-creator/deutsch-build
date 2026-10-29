import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class IndicLanguagesRegistry {
  static const LanguageProfile hindiProfile = LanguageProfile(
    isoCode: 'hi',
    autonym: 'हिन्दी',
    englishName: 'Hindi',
    scriptDirection: 'ltr',
    scriptFamily: 'Devanagari',
    typology: 'SOV',
    morphologyType: 'Fusional',
    casesCount: 3,
    caseNames: ['Direct', 'Oblique', 'Vocative'],
    genders: ['m', 'f'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile marathiProfile = LanguageProfile(
    isoCode: 'mr',
    autonym: 'मराठी',
    englishName: 'Marathi',
    scriptDirection: 'ltr',
    scriptFamily: 'Devanagari',
    typology: 'SOV',
    morphologyType: 'Fusional',
    casesCount: 4,
    caseNames: ['Direct', 'Oblique', 'Instrumental', 'Locative'],
    genders: ['m', 'f', 'n'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(hindiProfile);
    engine.registerProfile(marathiProfile);
  }
}
