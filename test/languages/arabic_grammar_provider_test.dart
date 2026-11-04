import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/languages/arabic/arabic_grammar_provider.dart';

void main() {
  group('ArabicGrammarProvider - Arabic Linguistic Capabilities', () {
    final provider = ArabicGrammarProvider.instance;

    test('profile correctly specifies Arabic grammar capability profile', () {
      expect(provider.languageCode, equals('ar'));
      final profile = provider.profile;

      // Genders: masculine, feminine (no neuter)
      expect(profile.supportedGenders, contains(GrammaticalGender.masculine));
      expect(profile.supportedGenders, contains(GrammaticalGender.feminine));
      expect(profile.supportedGenders, isNot(contains(GrammaticalGender.neuter)));

      // Cases: nominative, accusative, genitive
      expect(profile.supportedCases, contains(GrammaticalCase.nominative));
      expect(profile.supportedCases, contains(GrammaticalCase.accusative));
      expect(profile.supportedCases, contains(GrammaticalCase.genitive));

      // Numbers: singular, dual, plural
      expect(profile.supportedNumbers, contains(GrammaticalNumber.singular));
      expect(profile.supportedNumbers, contains(GrammaticalNumber.dual));
      expect(profile.supportedNumbers, contains(GrammaticalNumber.plural));

      // Morphology: root-pattern
      expect(profile.morphologyType, equals(MorphologyType.rootPattern));
      expect(profile.supportsAgreement, isTrue);
    });

    test('metadata and legacy capabilities describe the same Arabic profile', () {
      expect(provider.profile.languageCode, provider.languageCode);
      expect(provider.capabilityProfile.hasGender, isTrue);
      expect(provider.capabilityProfile.hasCases, isTrue);
      expect(provider.capabilityProfile.hasNumber, isTrue);
      expect(provider.capabilityProfile.hasRootPatternMorphology, isTrue);
      expect(provider.supportsFeature(GrammarFeature.grammaticalCase), isTrue);
    });

    test('heuristics never claim a verified corpus record or pack revision', () {
      for (final word in ['كتاب', 'مدرسة', '', 'unseen']) {
        final evidence = provider.getVerifiedEvidence(word);
        expect(evidence.isSupported, isFalse);
        expect(evidence.packRevision, isNull);
        expect(evidence.root, isNull);
        expect(evidence.pattern, isNull);
      }
    });

    test('determines feminine gender via taa marbuta, alif maqsura, and semantic femininity', () {
      expect(provider.determineGender('مدرسة'), equals(GrammaticalGender.feminine));
      expect(provider.determineGender('سيارة'), equals(GrammaticalGender.feminine));
      expect(provider.determineGender('كبرى'), equals(GrammaticalGender.feminine));
      expect(provider.determineGender('صحراء'), equals(GrammaticalGender.feminine));
      expect(provider.determineGender('شمس'), equals(GrammaticalGender.feminine));
      expect(provider.determineGender('أرض'), equals(GrammaticalGender.feminine));

      // Masculine nouns
      expect(provider.determineGender('كتاب'), equals(GrammaticalGender.masculine));
      expect(provider.determineGender('قلم'), equals(GrammaticalGender.masculine));
      expect(provider.determineGender('بيت'), equals(GrammaticalGender.masculine));
      expect(provider.determineGender('ولد'), equals(GrammaticalGender.masculine));
    });

    test('determines categories for particles, nouns, and verbs', () {
      expect(provider.determineCategory('في'), equals(GrammaticalCategory.particle));
      expect(provider.determineCategory('إلى'), equals(GrammaticalCategory.particle));
      expect(provider.determineCategory('الكتاب'), equals(GrammaticalCategory.noun));
      expect(provider.determineCategory('جامعة'), equals(GrammaticalCategory.noun));
      expect(provider.determineCategory('كتبتُ'), equals(GrammaticalCategory.verb));
      expect(provider.determineCategory('درسوا'), equals(GrammaticalCategory.verb));
    });

    test('validates Arabic definite article Al-', () {
      expect(provider.isValidArticle('كتاب', 'ال'), isTrue);
      expect(provider.isValidArticle('كتاب', 'الـ'), isTrue);
      expect(provider.isValidArticle('كتاب', 'der'), isFalse);
    });
  });
}
