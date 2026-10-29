import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';

class GermanGrammarProvider implements LanguageGrammarRuleProvider {
  static final GermanGrammarProvider instance = GermanGrammarProvider._internal();
  GermanGrammarProvider._internal();

  @override
  String get languageCode => 'de';

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    final lowerArticle = article?.trim().toLowerCase();
    if (lowerArticle == 'der') return GrammaticalGender.masculine;
    if (lowerArticle == 'die') return GrammaticalGender.feminine;
    if (lowerArticle == 'das') return GrammaticalGender.neuter;

    final lowerWord = word.trim().toLowerCase();

    // قواعد اللواحق الصرفية القياسية للمؤنث في الألمانية
    if (lowerWord.endsWith('ung') ||
        lowerWord.endsWith('heit') ||
        lowerWord.endsWith('keit') ||
        lowerWord.endsWith('schaft') ||
        lowerWord.endsWith('tät') ||
        lowerWord.endsWith('ion')) {
      return GrammaticalGender.feminine;
    }

    // نهايات التصغير للمحايد
    if (lowerWord.endsWith('chen') || lowerWord.endsWith('lein')) {
      return GrammaticalGender.neuter;
    }

    // نهايات المذكر الشائعة
    if (lowerWord.endsWith('ismus') || lowerWord.endsWith('or')) {
      return GrammaticalGender.masculine;
    }

    return GrammaticalGender.none;
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    if (article != null && ['der', 'die', 'das', 'den', 'dem', 'des'].contains(article.toLowerCase())) {
      return GrammaticalCategory.noun;
    }
    final trimmed = word.trim();
    if (trimmed.isNotEmpty && trimmed[0] == trimmed[0].toUpperCase()) {
      return GrammaticalCategory.noun;
    }
    if (trimmed.endsWith('en') || trimmed.endsWith('ern') || trimmed.endsWith('eln')) {
      return GrammaticalCategory.verb;
    }
    return GrammaticalCategory.unknown;
  }

  @override
  bool isValidArticle(String word, String article) {
    final expectedGender = determineGender(word);
    final inputGender = determineGender(word, article: article);
    if (expectedGender == GrammaticalGender.none) return true;
    return expectedGender == inputGender;
  }
}
