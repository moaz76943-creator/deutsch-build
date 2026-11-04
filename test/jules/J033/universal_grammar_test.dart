import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/grammar_profile.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/grammar_capabilities.dart';


class MockSemiticGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'ar';

  @override
  GrammarCapabilityProfile get profile => GrammarCapabilityProfile(
        supportedGenders: {GrammaticalGender.masculine, GrammaticalGender.feminine},
        supportedNumbers: {GrammaticalNumber.singular, GrammaticalNumber.dual, GrammaticalNumber.plural},
        morphologyType: MorphologyType.rootPattern,
        supportsAgreement: true,
      );

  @override
  VerifiedGrammarEvidence getVerifiedEvidence(String word) {
    if (word == 'kataba') {
      return const VerifiedGrammarEvidence(
        isSupported: true,
        root: 'k-t-b',
        pattern: 'CaCaCa',
        tense: GrammaticalTense.past,
        person: GrammaticalPerson.third,
      );
    }
    return VerifiedGrammarEvidence.unsupported();
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) => GrammaticalCategory.unknown;

  @override
  GrammaticalGender determineGender(String word, {String? article}) => GrammaticalGender.none;

  @override
  bool isValidArticle(String word, String article) => false;
}

class MockGermanicGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'de';

  @override
  GrammarCapabilityProfile get profile => GrammarCapabilityProfile(
        supportedGenders: {GrammaticalGender.masculine, GrammaticalGender.feminine, GrammaticalGender.neuter},
        supportedCases: {GrammaticalCase.nominative, GrammaticalCase.accusative, GrammaticalCase.dative, GrammaticalCase.genitive},
        morphologyType: MorphologyType.inflectional,
        supportsAgreement: true,
      );

  @override
  VerifiedGrammarEvidence getVerifiedEvidence(String word) {
    if (word == 'gegangen') {
      return const VerifiedGrammarEvidence(
        isSupported: true,
        tense: GrammaticalTense.past,
        aspect: GrammaticalAspect.perfective,
      );
    }
    return VerifiedGrammarEvidence.unsupported();
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) => GrammaticalCategory.unknown;

  @override
  GrammaticalGender determineGender(String word, {String? article}) => GrammaticalGender.none;

  @override
  bool isValidArticle(String word, String article) => false;
}

class MockAnalyticGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'zh';

  @override
  GrammarCapabilityProfile get profile => GrammarCapabilityProfile(
        morphologyType: MorphologyType.analytic,
        supportsAgreement: false,
      );

  @override
  VerifiedGrammarEvidence getVerifiedEvidence(String word) {
    if (word == 'le') { // aspect particle
      return const VerifiedGrammarEvidence(
        isSupported: true,
        aspect: GrammaticalAspect.perfective,
      );
    }
    return VerifiedGrammarEvidence.unsupported();
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) => GrammaticalCategory.unknown;

  @override
  GrammaticalGender determineGender(String word, {String? article}) => GrammaticalGender.none;

  @override
  bool isValidArticle(String word, String article) => false;
}

void main() {
  group('Universal Grammar Capability Engine Tests', () {
    test('Semitic Language Profile', () {
      final provider = MockSemiticGrammarProvider();
      expect(provider.languageCode, 'ar');
      expect(provider.profile.morphologyType, MorphologyType.rootPattern);
      expect(provider.profile.supportedNumbers.contains(GrammaticalNumber.dual), true);

      final evidence = provider.getVerifiedEvidence('kataba');
      expect(evidence.isSupported, true);
      expect(evidence.root, 'k-t-b');
      expect(evidence.pattern, 'CaCaCa');
      expect(evidence.tense, GrammaticalTense.past);
      expect(evidence.person, GrammaticalPerson.third);

      final unsupported = provider.getVerifiedEvidence('unknown_word');
      expect(unsupported.isSupported, false);
    });

    test('Germanic Language Profile', () {
      final provider = MockGermanicGrammarProvider();
      expect(provider.languageCode, 'de');
      expect(provider.profile.morphologyType, MorphologyType.inflectional);
      expect(provider.profile.supportedCases.length, 4);

      final evidence = provider.getVerifiedEvidence('gegangen');
      expect(evidence.isSupported, true);
      expect(evidence.tense, GrammaticalTense.past);
      expect(evidence.aspect, GrammaticalAspect.perfective);
    });

    test('Analytic Language Profile', () {
      final provider = MockAnalyticGrammarProvider();
      expect(provider.languageCode, 'zh');
      expect(provider.profile.morphologyType, MorphologyType.analytic);
      expect(provider.profile.supportedGenders.isEmpty, true);
      expect(provider.profile.supportedCases.isEmpty, true);

      final evidence = provider.getVerifiedEvidence('le');
      expect(evidence.isSupported, true);
      expect(evidence.aspect, GrammaticalAspect.perfective);
    });

    test('Default Fallbacks for Unsupported Language', () {
      // Create an anonymous subclass to test default behavior
      final defaultProvider = _DefaultGrammarProvider();
      expect(defaultProvider.profile.morphologyType, MorphologyType.unknown);
      expect(defaultProvider.profile.supportedGenders.isEmpty, true);
      expect(defaultProvider.profile.supportsAgreement, false);

      final evidence = defaultProvider.getVerifiedEvidence('anything');
      expect(evidence.isSupported, false);
    });
  });
}

class _DefaultGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'xx';

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) => GrammaticalCategory.unknown;

  @override
  GrammaticalGender determineGender(String word, {String? article}) => GrammaticalGender.none;

  @override
  bool isValidArticle(String word, String article) => false;
}
