import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/grammar_profile.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/grammar_capabilities.dart';


import 'fixtures.dart';

void main() {
  group('Universal Language Grammar Capability Engine (J033)', () {
    test('Germanic (Inflectional) capabilities', () {
      final provider = GermanGrammarProviderMock();

      expect(provider.capabilityProfile.hasGender, isTrue);
      expect(provider.capabilityProfile.hasCases, isTrue);
      expect(provider.capabilityProfile.hasRootPatternMorphology, isFalse);
      expect(provider.capabilityProfile.isAnalytic, isFalse);
      expect(provider.capabilityProfile.isAgglutinative, isFalse);

      expect(provider.determineGender('Hund', article: 'der'), GrammaticalGender.masculine);
      expect(provider.determineCase('dem Hund', context: 'mit'), GrammaticalCase.dative);

      // Features German doesn't have in this simplified model
      expect(provider.extractRoot('Hund'), isNull);
      expect(provider.extractAffixes('Hund'), isNull);
    });

    test('Semitic (Root-pattern) capabilities', () {
      final provider = ArabicGrammarProvider();

      expect(provider.capabilityProfile.hasGender, isTrue);
      expect(provider.capabilityProfile.hasRootPatternMorphology, isTrue);

      expect(provider.determineGender('سيارة'), GrammaticalGender.feminine);
      expect(provider.determineNumber('كتابان'), GrammaticalNumber.dual);
      expect(provider.determineNumber('كتب'), GrammaticalNumber.singular); // Fallback for simple mock

      expect(provider.extractRoot('كتاب'), 'ك ت ب');
      expect(provider.extractPattern('كتاب'), 'فِعَال');

      // Arabic isn't typically modeled as strictly agglutinative in this engine
      expect(provider.extractAffixes('كتاب'), isNull);
    });

    test('Turkic (Agglutinative) capabilities', () {
      final provider = TurkishGrammarProvider();

      expect(provider.capabilityProfile.isAgglutinative, isTrue);
      expect(provider.capabilityProfile.hasCases, isTrue);
      expect(provider.capabilityProfile.hasGender, isFalse);

      expect(provider.determineGender('ev'), GrammaticalGender.none);
      expect(provider.isValidArticle('ev', 'the'), isFalse);

      expect(provider.extractAffixes('evlerimizde'), ['ler', 'imiz', 'de']);
      expect(provider.determineNumber('evler'), GrammaticalNumber.plural);
      expect(provider.determineCase('evde'), GrammaticalCase.locative);

      // No root pattern
      expect(provider.extractRoot('evlerimizde'), isNull);
    });

    test('Sino-Tibetan (Analytic) capabilities', () {
      final provider = ChineseGrammarProvider();

      expect(provider.capabilityProfile.isAnalytic, isTrue);
      expect(provider.capabilityProfile.hasGender, isFalse);
      expect(provider.capabilityProfile.hasCases, isFalse);
      expect(provider.capabilityProfile.hasTense, isFalse);

      expect(provider.determineGender('书'), GrammaticalGender.none);

      // Explicitly unavailable features return null
      expect(provider.determineCase('书'), isNull);
      expect(provider.determineTense('写'), isNull);
      expect(provider.determineNumber('人'), isNull);
      expect(provider.extractRoot('书'), isNull);
      expect(provider.extractAffixes('书'), isNull);
    });

    test('Base provider interface maintains backward compatibility without exceptions', () {
      // Create an anonymous subclass that overrides nothing extra
      final basicProvider = _BasicProvider();

      // Default profile should be false for everything
      expect(basicProvider.capabilityProfile.hasGender, isFalse);
      expect(basicProvider.capabilityProfile.hasCases, isFalse);

      // Legacy methods
      expect(basicProvider.determineGender('word'), GrammaticalGender.none);
      expect(basicProvider.determineCategory('word'), GrammaticalCategory.unknown);
      expect(basicProvider.isValidArticle('word', 'art'), isTrue);

      // New methods should return null gracefully
      expect(basicProvider.determineCase('word'), isNull);
      expect(basicProvider.determineTense('word'), isNull);
      expect(basicProvider.extractRoot('word'), isNull);
      expect(basicProvider.extractAffixes('word'), isNull);
      expect(basicProvider.determineNounClass('word'), isNull);
    });
  });
}

class _BasicProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'basic';

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) => GrammaticalCategory.unknown;

  @override
  GrammaticalGender determineGender(String word, {String? article}) => GrammaticalGender.none;

  @override
  bool isValidArticle(String word, String article) => true;
}
