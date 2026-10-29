import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

class UralicLanguagesRegistry {
  static const LanguageProfile hungarianProfile = LanguageProfile(
    isoCode: 'hu',
    autonym: 'Magyar',
    englishName: 'Hungarian',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Agglutinative',
    casesCount: 18,
    caseNames: ['Alanyeset', 'Tárgyeset', 'Részeshatározó', 'Birtokos', 'Inessive', 'Superessive', 'Adessive', 'Illative', 'Sublative', 'Allative', 'Elative', 'Delative', 'Ablative', 'Instrumental', 'Causal-Final', 'Translative', 'Terminative', 'Essive-Formal'],
    genders: ['none'],
    hasArticles: true,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static const LanguageProfile finnishProfile = LanguageProfile(
    isoCode: 'fi',
    autonym: 'Suomi',
    englishName: 'Finnish',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Agglutinative',
    casesCount: 15,
    caseNames: ['Nominatiivi', 'Genetiivi', 'Partitiivi', 'Essiivi', 'Translatiivi', 'Inessiivi', 'Elatiivi', 'Illatiivi', 'Adessiivi', 'Ablatiivi', 'Allatiivi', 'Abessiivi', 'Komitatiivi', 'Instruktiivi', 'Akusatiivi'],
    genders: ['none'],
    hasArticles: false,
    hasNounDeclension: true,
    hasVerbConjugation: true,
  );

  static void registerProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(hungarianProfile);
    engine.registerProfile(finnishProfile);
  }
}
