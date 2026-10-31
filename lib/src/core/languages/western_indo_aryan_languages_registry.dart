import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class WesternIndoAryanLanguagesRegistry {
  static const LanguageProfile punjabiProfile = LanguageProfile(
    isoCode: 'pa',
    autonym: 'ਪੰਜਾਬੀ',
    englishName: 'Punjabi',
    scriptDirection: 'ltr',
    scriptFamily: 'Gurmukhi',
    typology: 'SOV',
    morphologyType: 'Fusional',
    casesCount: 5,
    caseNames: ['Direct', 'Oblique', 'Vocative', 'Ablative', 'Locative'],
    genders: ['m', 'f'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile sindhiProfile = LanguageProfile(
    isoCode: 'sd',
    autonym: 'سنڌي',
    englishName: 'Sindhi',
    scriptDirection: 'rtl',
    scriptFamily: 'Perso-Arabic (Extended)',
    typology: 'SOV',
    morphologyType: 'Fusional',
    casesCount: 4,
    caseNames: ['Direct', 'Oblique', 'Vocative', 'Locative'],
    genders: ['m', 'f'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(punjabiProfile);
    engine.registerProfile(sindhiProfile);
  }
}
