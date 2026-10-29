import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class BalkanLanguagesRegistry {
  static const LanguageProfile greekProfile = LanguageProfile(
    isoCode: 'el',
    autonym: 'Ελληνικά',
    englishName: 'Greek',
    scriptDirection: 'ltr',
    scriptFamily: 'Greek',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 4,
    caseNames: ['Ονομαστική', 'Γενική', 'Αιτιατική', 'Κλητική'],
    genders: ['m', 'f', 'n'],
    hasArticles: true,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile romanianProfile = LanguageProfile(
    isoCode: 'ro',
    autonym: 'Română',
    englishName: 'Romanian',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 3,
    caseNames: ['Nominativ-Acuzativ', 'Genitiv-Dativ', 'Vocativ'],
    genders: ['m', 'f', 'n'],
    hasArticles: true,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(greekProfile);
    engine.registerProfile(romanianProfile);
  }
}
