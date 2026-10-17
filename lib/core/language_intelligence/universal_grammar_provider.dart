import 'language_grammar_rule_provider.dart';
import 'grammar_capabilities.dart';
import 'grammar_profile.dart';

abstract class UniversalGrammarProvider implements LanguageGrammarRuleProvider {
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
  GrammaticalNumber determineNumber(String word) {
    if (!profile.supports(GrammarCapability.number)) {
      return GrammaticalNumber.none;
    }
    return extractNumber(word);
  }

  GrammaticalNumber extractNumber(String word) => GrammaticalNumber.none;

  @override
  GrammaticalCase determineCase(String word) {
    if (!profile.supports(GrammarCapability.caseSystem)) {
      return GrammaticalCase.none;
    }
    return extractCase(word);
  }

  GrammaticalCase extractCase(String word) => GrammaticalCase.none;

  @override
  GrammaticalPerson determinePerson(String word) {
    if (!profile.supports(GrammarCapability.person)) {
      return GrammaticalPerson.none;
    }
    return extractPerson(word);
  }

  GrammaticalPerson extractPerson(String word) => GrammaticalPerson.none;

  @override
  GrammaticalTense determineTense(String word) {
    if (!profile.supports(GrammarCapability.tense)) {
      return GrammaticalTense.none;
    }
    return extractTense(word);
  }

  GrammaticalTense extractTense(String word) => GrammaticalTense.none;

  @override
  GrammaticalAspect determineAspect(String word) {
    if (!profile.supports(GrammarCapability.aspect)) {
      return GrammaticalAspect.none;
    }
    return extractAspect(word);
  }

  GrammaticalAspect extractAspect(String word) => GrammaticalAspect.none;

  @override
  GrammaticalMood determineMood(String word) {
    if (!profile.supports(GrammarCapability.mood)) return GrammaticalMood.none;
    return extractMood(word);
  }

  GrammaticalMood extractMood(String word) => GrammaticalMood.none;
}
