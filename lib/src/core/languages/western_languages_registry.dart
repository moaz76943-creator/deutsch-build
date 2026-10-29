import 'dart:convert';
import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';

/// Registry providing statically compiled and asset-driven Western language profiles.
class WesternLanguagesRegistry {
  static const LanguageProfile englishProfile = LanguageProfile(
    isoCode: 'en',
    autonym: 'English',
    englishName: 'English',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['none'],
    hasArticles: true,
    hasNounDeclension: false,
    hasVerbConjugation: true,
  );

  static const LanguageProfile frenchProfile = LanguageProfile(
    isoCode: 'fr',
    autonym: 'Français',
    englishName: 'French',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['m', 'f'],
    hasArticles: true,
    hasNounDeclension: false,
    hasVerbConjugation: true,
  );

  static const LanguageProfile spanishProfile = LanguageProfile(
    isoCode: 'es',
    autonym: 'Español',
    englishName: 'Spanish',
    scriptDirection: 'ltr',
    scriptFamily: 'Latin',
    typology: 'SVO',
    morphologyType: 'Fusional',
    casesCount: 0,
    caseNames: [],
    genders: ['m', 'f'],
    hasArticles: true,
    hasNounDeclension: false,
    hasVerbConjugation: true,
  );

  /// Registers English, French, and Spanish into the global engine.
  static void registerWesternProfiles(DeclarativeLanguageEngine engine) {
    engine.registerProfile(englishProfile);
    engine.registerProfile(frenchProfile);
    engine.registerProfile(spanishProfile);
  }
}
