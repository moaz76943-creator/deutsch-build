import 'language_grammar_rule_provider.dart';

abstract class UniversalGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  GrammarProfile get profile;

  @override
  String get languageCode => profile.languageCode;

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    if (!profile.supports(GrammarCapability.gender)) {
      return GrammaticalGender.none;
    }
    return extractGender(word, article: article);
  }

  GrammaticalGender extractGender(String word, {String? article}) {
    return GrammaticalGender.none;
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    return extractCategory(word, article: article);
  }

  GrammaticalCategory extractCategory(String word, {String? article}) {
    return GrammaticalCategory.unknown;
  }

  @override
  bool isValidArticle(String word, String article) {
    if (!profile.supports(GrammarCapability.gender)) {
      return true; // Or whatever makes sense for a language without articles/gender
    }
    return checkValidArticle(word, article);
  }

  bool checkValidArticle(String word, String article) {
    return true;
  }

  // Capability-guarded properties

  @override
  GrammaticalNumber? determineNumber(String word) {
    if (!profile.supports(GrammarCapability.number)) return null;
    return extractNumber(word);
  }

  GrammaticalNumber extractNumber(String word) => GrammaticalNumber.none;

  @override
  GrammaticalCase determineCase(String word, {String? context}) {
    if (!profile.supports(GrammarCapability.caseSystem)) {
      return GrammaticalCase.none;
    }
    return extractCase(word);
  }

  GrammaticalCase extractCase(String word, {String? context}) =>
      GrammaticalCase.none;

  @override
  GrammaticalPerson? determinePerson(String word) {
    if (!profile.supports(GrammarCapability.person)) return null;
    return extractPerson(word);
  }

  GrammaticalPerson extractPerson(String word) => GrammaticalPerson.none;

  @override
  Tense? determineTense(String word) {
    if (!profile.supports(GrammarCapability.tense)) return null;
    return extractTense(word);
  }

  Tense extractTense(String word) => Tense.none;

  @override
  Aspect? determineAspect(String word) {
    if (!profile.supports(GrammarCapability.aspect)) return null;
    return extractAspect(word);
  }

  Aspect extractAspect(String word) => Aspect.none;

  @override
  Mood? determineMood(String word) {
    if (!profile.supports(GrammarCapability.mood)) return null;
    return extractMood(word);
  }

  Mood extractMood(String word) => Mood.none;
}
