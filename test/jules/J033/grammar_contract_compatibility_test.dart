import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';

class LegacyProvider extends LanguageGrammarRuleProvider {
  LegacyProvider({this.hasTense = false});
  final bool hasTense;

  @override
  String get languageCode => 'test';
  @override
  GrammarCapabilityProfile get capabilityProfile =>
      GrammarCapabilityProfile(hasTense: hasTense);
  @override
  GrammaticalGender determineGender(String word, {String? article}) =>
      GrammaticalGender.none;
  @override
  GrammaticalCategory determineCategory(String word, {String? article}) =>
      GrammaticalCategory.unknown;
  @override
  bool isValidArticle(String word, String article) => true;
}

class DeclarativeProvider extends LegacyProvider {
  @override
  GrammarProfile get profile => const GrammarProfile(
        supportedFeatures: {GrammarFeature.tense},
      );
}

void main() {
  test('legacy nullable fallback distinguishes absent from unknown tense', () {
    expect(LegacyProvider().determineTense('word'), isNull);
    expect(
        LegacyProvider(hasTense: true).determineTense('word'), Tense.unknown);
  });

  test('declarative provider retains explicit none fallback', () {
    expect(DeclarativeProvider().determineTense('word'), Tense.none);
  });

  test('grammar type aliases preserve existing enum identities', () {
    expect(GrammaticalTense.past, Tense.past);
    expect(GrammaticalAspect.perfective, Aspect.perfective);
    expect(GrammaticalMood.imperative, Mood.imperative);
  });

  test('case feature names are interchangeable without enabling other features',
      () {
    for (final feature in [
      GrammarFeature.grammaticalCase,
      GrammarFeature.caseSystem
    ]) {
      final profile = GrammarProfile(supportedFeatures: {feature});
      expect(profile.supports(GrammarCapability.caseSystem), isTrue);
      expect(profile.supportsFeature(GrammarFeature.grammaticalCase), isTrue);
      expect(profile.supportsFeature(GrammarFeature.gender), isFalse);
    }
  });
}
