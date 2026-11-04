import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/grammar_profile.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/grammar_capabilities.dart';


class ArabicGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'ar';

  @override
  GrammarCapabilityProfile get capabilityProfile => GrammarCapabilityProfile(
        hasGender: true,
        hasCases: true, // Nominative, Accusative, Genitive
        hasNumber: true, // Singular, Dual, Plural
        hasPerson: true,
        hasTense: true,
        hasAspect: true,
        hasMood: true,
        hasRootPatternMorphology: true,
      );

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    if (word.endsWith('ة') || word.endsWith('اء') || word.endsWith('ى')) {
      return GrammaticalGender.feminine;
    }
    return GrammaticalGender.masculine; // Defaulting for simple mock
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    if (article == 'ال') return GrammaticalCategory.noun;
    return GrammaticalCategory.unknown;
  }

  @override
  bool isValidArticle(String word, String article) {
    return article == 'ال'; // Arabic definite article
  }

  @override
  GrammaticalNumber? determineNumber(String word, {String? context}) {
    if (word.endsWith('ان') || word.endsWith('ين')) return GrammaticalNumber.dual;
    if (word.endsWith('ون') || word.endsWith('ات')) return GrammaticalNumber.plural;
    return GrammaticalNumber.singular;
  }

  @override
  String? extractRoot(String word) {
    // Very simplified mock root extractor
    if (word == 'كتاب') return 'ك ت ب';
    if (word == 'مدرسة') return 'د ر س';
    return null;
  }

  @override
  String? extractPattern(String word) {
    if (word == 'كتاب') return 'فِعَال';
    return null;
  }

  @override
  GrammaticalPerson? determinePerson(String word) {
    return GrammaticalPerson.unknown;
  }

  @override
  GrammaticalCase? determineCase(String word, {String? context}) {
    return GrammaticalCase.unknown;
  }

  @override
  Tense? determineTense(String word) {
    return Tense.unknown;
  }

  @override
  Aspect? determineAspect(String word) {
    return Aspect.unknown;
  }

  @override
  Mood? determineMood(String word) {
    return Mood.unknown;
  }

  @override
  List<String>? extractAffixes(String word) {
    return null;
  }

  @override
  String? determineNounClass(String word) {
    return null;
  }
}

class TurkishGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'tr';

  @override
  GrammarCapabilityProfile get capabilityProfile => GrammarCapabilityProfile(
        isAgglutinative: true,
        hasCases: true,
        hasNumber: true,
        hasPerson: true,
        hasTense: true,
        hasAspect: true,
        hasMood: true,
      );

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    return GrammaticalGender.none; // Turkish has no grammatical gender
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    return GrammaticalCategory.unknown;
  }

  @override
  bool isValidArticle(String word, String article) {
    return false; // Turkish has no articles
  }

  @override
  List<String>? extractAffixes(String word) {
    if (word == 'evlerimizde') return ['ler', 'imiz', 'de'];
    return [];
  }

  @override
  GrammaticalNumber? determineNumber(String word, {String? context}) {
    if (word.contains('lar') || word.contains('ler')) return GrammaticalNumber.plural;
    return GrammaticalNumber.singular;
  }

  @override
  GrammaticalPerson? determinePerson(String word) {
    return GrammaticalPerson.unknown;
  }

  @override
  GrammaticalCase? determineCase(String word, {String? context}) {
    if (word.endsWith('de') || word.endsWith('da')) return GrammaticalCase.locative;
    return GrammaticalCase.unknown;
  }

  @override
  Tense? determineTense(String word) {
    return Tense.unknown;
  }

  @override
  Aspect? determineAspect(String word) {
    return Aspect.unknown;
  }

  @override
  Mood? determineMood(String word) {
    return Mood.unknown;
  }

  @override
  String? extractRoot(String word) {
    return null;
  }

  @override
  String? extractPattern(String word) {
    return null;
  }

  @override
  String? determineNounClass(String word) {
    return null;
  }
}

class ChineseGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'zh';

  @override
  GrammarCapabilityProfile get capabilityProfile => GrammarCapabilityProfile(
        isAnalytic: true,
      );

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    return GrammaticalGender.none;
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    return GrammaticalCategory.unknown;
  }

  @override
  bool isValidArticle(String word, String article) {
    return false; // Chinese has no articles, uses measure words
  }

  @override
  GrammaticalNumber? determineNumber(String word, {String? context}) => null;

  @override
  GrammaticalPerson? determinePerson(String word) => null;

  @override
  GrammaticalCase? determineCase(String word, {String? context}) => null;

  @override
  Tense? determineTense(String word) => null;

  @override
  Aspect? determineAspect(String word) => null;

  @override
  Mood? determineMood(String word) => null;

  @override
  String? extractRoot(String word) => null;

  @override
  String? extractPattern(String word) => null;

  @override
  List<String>? extractAffixes(String word) => null;

  @override
  String? determineNounClass(String word) => null;
}

class GermanGrammarProviderMock extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'de';

  @override
  GrammarCapabilityProfile get capabilityProfile => GrammarCapabilityProfile(
        hasGender: true,
        hasCases: true,
        hasNumber: true,
        hasPerson: true,
        hasTense: true,
        hasMood: true,
      );

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    if (article == 'der') return GrammaticalGender.masculine;
    if (article == 'die') return GrammaticalGender.feminine;
    if (article == 'das') return GrammaticalGender.neuter;
    return GrammaticalGender.none;
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    return GrammaticalCategory.unknown;
  }

  @override
  bool isValidArticle(String word, String article) {
    final expected = determineGender(word, article: article);
    return expected != GrammaticalGender.none;
  }

  @override
  GrammaticalCase? determineCase(String word, {String? context}) {
    if (context == 'mit') return GrammaticalCase.dative;
    return GrammaticalCase.unknown;
  }

  @override
  GrammaticalNumber? determineNumber(String word, {String? context}) => GrammaticalNumber.unknown;

  @override
  GrammaticalPerson? determinePerson(String word) => GrammaticalPerson.unknown;

  @override
  Tense? determineTense(String word) => Tense.unknown;

  @override
  Aspect? determineAspect(String word) => null; // German aspect is debatable but we use null for simplicity here

  @override
  Mood? determineMood(String word) => Mood.unknown;

  @override
  String? extractRoot(String word) => null;

  @override
  String? extractPattern(String word) => null;

  @override
  List<String>? extractAffixes(String word) => null;

  @override
  String? determineNounClass(String word) => null;
}
