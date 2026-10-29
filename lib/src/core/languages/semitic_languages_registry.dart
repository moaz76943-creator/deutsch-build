import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class SemiticLanguagesRegistry {
  static const LanguageProfile malteseProfile = LanguageProfile(
    isoCode: 'mt',
    autonym: 'Malti',
    englishName: 'Maltese',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin (Maltese)',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['m', 'f'],
    hasArticles: true,
    hasNounDeclension: false,
    hasVerbConjugation: true,
    hasDualNumber: true,
  );

  static const LanguageProfile syriacProfile = LanguageProfile(
    isoCode: 'syc',
    autonym: 'ܣܘܪܝܝܐ',
    englishName: 'Classical Syriac',
    scriptDirection: 'rtl',
    scriptFamily: 'Syriac',
    typology: 'VSO',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['m', 'f'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
    hasDualNumber: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(malteseProfile);
    engine.registerProfile(syriacProfile);
  }
}
