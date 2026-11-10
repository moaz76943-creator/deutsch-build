import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';

// Dummy Analytic Language (e.g., English)
class EnglishGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'en';

  @override
  GrammarProfile get profile => const GrammarProfile(
        supportedFeatures: {
          GrammarFeature.analytic,
          GrammarFeature.number,
          GrammarFeature.tense,
        },
        supportedNumbers: {GrammaticalNumber.singular, GrammaticalNumber.plural},
      );

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    return GrammaticalGender.none; // English mostly doesn't have grammatical gender
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    if (article == 'the' || article == 'a' || article == 'an') {
      return GrammaticalCategory.noun;
    }
    return GrammaticalCategory.unknown;
  }

  @override
  bool isValidArticle(String word, String article) {
    return ['the', 'a', 'an'].contains(article.toLowerCase());
  }

  @override
  GrammaticalNumber determineNumber(String word, {String? context}) {
    if (word.endsWith('s')) return GrammaticalNumber.plural;
    return GrammaticalNumber.singular;
  }
}

// Dummy Semitic Language with Root-Pattern (e.g., Arabic)
class ArabicGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'ar';

  @override
  GrammarProfile get profile => const GrammarProfile(
        supportedFeatures: {
          GrammarFeature.gender,
          GrammarFeature.number,
          GrammarFeature.rootPattern,
          GrammarFeature.grammaticalCase,
          GrammarFeature.agreement,
        },
        supportedGenders: {GrammaticalGender.masculine, GrammaticalGender.feminine},
        supportedNumbers: {
          GrammaticalNumber.singular,
          GrammaticalNumber.dual,
          GrammaticalNumber.plural
        },
        supportedCases: {
          GrammaticalCase.nominative,
          GrammaticalCase.accusative,
          GrammaticalCase.genitive
        },
      );

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    if (word.endsWith('ة')) return GrammaticalGender.feminine;
    return GrammaticalGender.masculine; // simplified for testing
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    if (article == 'ال') return GrammaticalCategory.noun;
    return GrammaticalCategory.unknown;
  }

  @override
  bool isValidArticle(String word, String article) {
    return article == 'ال';
  }
}

// Dummy Agglutinative Language (e.g., Turkish)
class TurkishGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'tr';

  @override
  GrammarProfile get profile => const GrammarProfile(
        supportedFeatures: {
          GrammarFeature.agglutinative,
          GrammarFeature.number,
          GrammarFeature.grammaticalCase,
        },
        supportedCases: {
          GrammaticalCase.nominative,
          GrammaticalCase.accusative,
          GrammaticalCase.dative,
          GrammaticalCase.locative,
          GrammaticalCase.ablative,
          GrammaticalCase.genitive,
        },
        supportedNumbers: {GrammaticalNumber.singular, GrammaticalNumber.plural},
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
    return false; // Turkish has no definite article
  }
}

void main() {
  group('Universal Language Grammar Capability Engine - J033', () {
    test('Analytic Language (English) supports appropriate features', () {
      final english = EnglishGrammarProvider();

      expect(english.languageCode, 'en');
      expect(english.profile.supports(GrammarFeature.analytic), isTrue);
      expect(english.profile.supports(GrammarFeature.gender), isFalse);
      expect(english.profile.supports(GrammarFeature.rootPattern), isFalse);
      expect(english.profile.supportsNumber(GrammaticalNumber.plural), isTrue);

      // determineGender should return none
      expect(english.determineGender('house'), GrammaticalGender.none);

      // determineNumber returns appropriate value
      expect(english.determineNumber('cats'), GrammaticalNumber.plural);

      // determineCase uses default implementation and returns none
      expect(english.determineCase('dog'), GrammaticalCase.none);
    });

    test('Semitic Language (Arabic) supports root-pattern and dual number', () {
      final arabic = ArabicGrammarProvider();

      expect(arabic.languageCode, 'ar');
      expect(arabic.profile.supports(GrammarFeature.rootPattern), isTrue);
      expect(arabic.profile.supports(GrammarFeature.gender), isTrue);
      expect(arabic.profile.supportsNumber(GrammaticalNumber.dual), isTrue);

      // determineGender works according to specific language logic
      expect(arabic.determineGender('سيارة'), GrammaticalGender.feminine);
      expect(arabic.determineGender('كتاب'), GrammaticalGender.masculine);

      // Default fallback handles unsupported tense correctly
      expect(arabic.determineTense('ذهب'), GrammaticalTense.none);
    });

    test('Agglutinative Language (Turkish) supports various cases but no gender', () {
      final turkish = TurkishGrammarProvider();

      expect(turkish.languageCode, 'tr');
      expect(turkish.profile.supports(GrammarFeature.agglutinative), isTrue);
      expect(turkish.profile.supports(GrammarFeature.gender), isFalse);
      expect(turkish.profile.supportsCase(GrammaticalCase.locative), isTrue);

      // gender returns none
      expect(turkish.determineGender('araba'), GrammaticalGender.none);
    });

    test('Default fallbacks are safe and do not throw exceptions', () {
      final english = EnglishGrammarProvider();

      // Calling all determine* methods that rely on defaults
      expect(() => english.determineCase('test'), returnsNormally);
      expect(english.determineCase('test'), GrammaticalCase.none);

      expect(() => english.determinePerson('test'), returnsNormally);
      expect(english.determinePerson('test'), GrammaticalPerson.none);

      expect(() => english.determineTense('test'), returnsNormally);
      expect(english.determineTense('test'), GrammaticalTense.none);

      expect(() => english.determineAspect('test'), returnsNormally);
      expect(english.determineAspect('test'), GrammaticalAspect.none);

      expect(() => english.determineMood('test'), returnsNormally);
      expect(english.determineMood('test'), GrammaticalMood.none);
    });
  });
}
