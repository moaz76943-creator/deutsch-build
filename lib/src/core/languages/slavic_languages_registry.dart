import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

/// Registry providing statically compiled and asset-driven Slavic language profiles.
class SlavicLanguagesRegistry {
  static const LanguageProfile russianProfile = LanguageProfile(
    isoCode: 'ru',
    autonym: 'Русский',
    englishName: 'Russian',
    scriptDirection: 'ltr',
    scriptFamily: 'Cyrillic',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 6,
    caseNames: ['Именительный', 'Родительный', 'Дательный', 'Винительный', 'Творительный', 'Предложный'],
    genders: ['m', 'f', 'n'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile ukrainianProfile = LanguageProfile(
    isoCode: 'uk',
    autonym: 'Українська',
    englishName: 'Ukrainian',
    scriptDirection: 'ltr',
    scriptFamily: 'Cyrillic',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 7,
    caseNames: ['Називний', 'Родовий', 'Давальний', 'Знахідний', 'Орудний', 'Місцевий', 'Кличний'],
    genders: ['m', 'f', 'n'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile polishProfile = LanguageProfile(
    isoCode: 'pl',
    autonym: 'Polski',
    englishName: 'Polish',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 7,
    caseNames: ['Mianownik', 'Dopełniacz', 'Celownik', 'Biernik', 'Narzędnik', 'Miejscownik', 'Wołacz'],
    genders: ['m', 'f', 'n'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  /// Registers Russian, Ukrainian, and Polish into the global engine.
  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(russianProfile);
    engine.registerProfile(ukrainianProfile);
    engine.registerProfile(polishProfile);
  }
}
