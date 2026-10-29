import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class VietnameseLanguageRegistry {
  static const LanguageProfile vietnameseProfile = LanguageProfile(
    isoCode: 'vi',
    autonym: 'Tiếng Việt',
    englishName: 'Vietnamese',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin (Chữ Quốc ngữ)',
    typology: 'SVO',
    morphologyType: 'Isolating',
    casesCount: 0,
    caseNames: [],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: false,
    hasVerbConjugation: false,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(vietnameseProfile);
  }
}
