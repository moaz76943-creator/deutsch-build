import 'language_grammar_rule_provider.dart';

abstract class UniversalGrammarProvider implements LanguageGrammarRuleProvider {
  @override
  GrammarProfile get profile;

  @override
  GrammarCapabilityProfile get capabilityProfile => const GrammarCapabilityProfile();

  @override
  String get languageCode => profile.languageCode;

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    if (!profile.supports(GrammarFeature.gender)) {
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
    if (!profile.supports(GrammarFeature.gender)) {
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
    if (!profile.supports(GrammarFeature.number)) return GrammaticalNumber.none;
    return extractNumber(word);
  }

  GrammaticalNumber extractNumber(String word) => GrammaticalNumber.none;

  @override
  GrammaticalCase? determineCase(String word, {String? context}) {
    if (!profile.supports(GrammarFeature.caseSystem) && !profile.supports(GrammarFeature.grammaticalCase)) return GrammaticalCase.none;
    return extractCase(word, context: context);
  }

  GrammaticalCase extractCase(String word, {String? context}) =>
      GrammaticalCase.none;

  @override
  GrammaticalPerson? determinePerson(String word) {
    if (!profile.supports(GrammarFeature.person)) return GrammaticalPerson.none;
    return extractPerson(word);
  }

  GrammaticalPerson extractPerson(String word) => GrammaticalPerson.none;

  @override
  Tense? determineTense(String word) {
    if (!profile.supports(GrammarFeature.tense)) return Tense.none;
    return extractTense(word);
  }

  Tense extractTense(String word) => Tense.none;

  @override
  Aspect? determineAspect(String word) {
    if (!profile.supports(GrammarFeature.aspect)) return Aspect.none;
    return extractAspect(word);
  }

  Aspect extractAspect(String word) => Aspect.none;

  @override
  Mood? determineMood(String word) {
    if (!profile.supports(GrammarFeature.mood)) return Mood.none;
    return extractMood(word);
  }

  Mood extractMood(String word) => Mood.none;

  @override
  String? extractRoot(String word) {
    if (!profile.supports(GrammarFeature.rootPattern)) return null;
    return extractRootImpl(word);
  }

  String? extractRootImpl(String word) => null;

  @override
  String? extractPattern(String word) {
    if (!profile.supports(GrammarFeature.rootPattern)) return null;
    return extractPatternImpl(word);
  }

  String? extractPatternImpl(String word) => null;

  @override
  List<String>? extractAffixes(String word) {
    if (!profile.supports(GrammarFeature.agglutinative)) return null;
    return extractAffixesImpl(word);
  }

  List<String>? extractAffixesImpl(String word) => [];

  @override
  String? determineNounClass(String word) {
    if (!profile.supports(GrammarFeature.nounClasses)) return null;
    return determineNounClassImpl(word);
  }

  String? determineNounClassImpl(String word) => null;
}
