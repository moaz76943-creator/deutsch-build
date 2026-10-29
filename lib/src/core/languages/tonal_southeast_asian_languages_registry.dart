import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class TonalSoutheastAsianLanguagesRegistry {
  static const LanguageProfile thaiProfile = LanguageProfile(
    isoCode: 'th',
    autonym: 'ไทย',
    englishName: 'Thai',
    scriptDirection: 'ltr',
    scriptFamily: 'Thai',
    typology: 'SVO',
    morphologyType: 'Isolating',
    casesCount: 0,
    caseNames: [],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: false,
    hasVerbConjugation: false,
  );

  static const LanguageProfile burmeseProfile = LanguageProfile(
    isoCode: 'my',
    autonym: 'မြန်မာစာ',
    englishName: 'Burmese',
    scriptDirection: 'ltr',
    scriptFamily: 'Burmese',
    typology: 'SOV',
    morphologyType: 'Isolating',
    casesCount: 0,
    caseNames: [],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: false,
    hasVerbConjugation: false,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(thaiProfile);
    engine.registerProfile(burmeseProfile);
  }
}
