import 'language_grammar_rule_provider.dart';

abstract class UniversalGrammarProvider implements LanguageGrammarRuleProvider {
  @override
  String get languageCode;

  @override
  GrammarProfile get profile => const GrammarProfile();

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    if (!profile.supportsFeature(GrammarFeature.gender)) {
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
    if (!profile.supportsFeature(GrammarFeature.gender)) {
      return true; // Or whatever makes sense for a language without articles/gender
    }
    return checkValidArticle(word, article);
  }

  bool checkValidArticle(String word, String article) {
    return true;
  }

  @override
  GrammaticalNumber determineNumber(String word, {String? context}) {
    if (!profile.supportsFeature(GrammarFeature.number)) return GrammaticalNumber.none;
    return extractNumber(word);
  }

  GrammaticalNumber extractNumber(String word) => GrammaticalNumber.none;

  @override
  GrammaticalCase determineCase(String word, {String? context}) {
    if (!profile.supportsFeature(GrammarFeature.grammaticalCase)) return GrammaticalCase.none;
    return extractCase(word);
  }

  GrammaticalCase extractCase(String word) => GrammaticalCase.none;

  @override
  GrammaticalPerson determinePerson(String word, {String? context}) {
    if (!profile.supportsFeature(GrammarFeature.person)) return GrammaticalPerson.none;
    return extractPerson(word);
  }

  GrammaticalPerson extractPerson(String word) => GrammaticalPerson.none;

  @override
  GrammaticalTense determineTense(String word, {String? context}) {
    if (!profile.supportsFeature(GrammarFeature.tense)) return GrammaticalTense.none;
    return extractTense(word);
  }

  GrammaticalTense extractTense(String word) => GrammaticalTense.none;

  @override
  GrammaticalAspect determineAspect(String word, {String? context}) {
    if (!profile.supportsFeature(GrammarFeature.aspect)) return GrammaticalAspect.none;
    return extractAspect(word);
  }

  GrammaticalAspect extractAspect(String word) => GrammaticalAspect.none;

  @override
  GrammaticalMood determineMood(String word, {String? context}) {
    if (!profile.supportsFeature(GrammarFeature.mood)) return GrammaticalMood.none;
    return extractMood(word);
  }

  GrammaticalMood extractMood(String word) => GrammaticalMood.none;

  @override
  bool supportsFeature(GrammarFeature feature) => profile.supportsFeature(feature);
}
