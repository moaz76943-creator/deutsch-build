import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

/// Registry providing statically compiled and asset-driven CJK East Asian language profiles.
class EastAsianLanguagesRegistry {
  static const LanguageProfile japaneseProfile = LanguageProfile(
    isoCode: 'ja',
    autonym: '日本語',
    englishName: 'Japanese',
    scriptDirection: 'ltr',
    scriptFamily: 'CJK (Kanji, Hiragana, Katakana)',
    typology: 'SOV',
    morphologyType: 'Agglutinative',
    casesCount: 0,
    caseNames: [],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: false,
    hasVerbConjugation: true,
  );

  static const LanguageProfile chineseProfile = LanguageProfile(
    isoCode: 'zh',
    autonym: '中文',
    englishName: 'Chinese',
    scriptDirection: 'ltr',
    scriptFamily: 'CJK (Hanzi)',
    typology: 'SVO',
    morphologyType: 'Isolating',
    casesCount: 0,
    caseNames: [],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: false,
    hasVerbConjugation: false,
  );

  static const LanguageProfile koreanProfile = LanguageProfile(
    isoCode: 'ko',
    autonym: '한국어',
    englishName: 'Korean',
    scriptDirection: 'ltr',
    scriptFamily: 'Hangul',
    typology: 'SOV',
    morphologyType: 'Agglutinative',
    casesCount: 0,
    caseNames: [],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: false,
    hasVerbConjugation: true,
  );

  /// Registers Japanese, Chinese, and Korean into the global engine.
  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(japaneseProfile);
    engine.registerProfile(chineseProfile);
    engine.registerProfile(koreanProfile);
  }
}
