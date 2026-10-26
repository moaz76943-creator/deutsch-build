import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/features/semantic_color_tagging/semantic_presentation_engine.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';

class MockDeProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'de';

  @override
  GrammarCapabilityProfile get capabilityProfile => const GrammarCapabilityProfile(
    hasGender: true,
    hasCases: true,
    hasNumber: true,
  );

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    if (word == 'Hund') return GrammaticalGender.masculine;
    if (word == 'Katze') return GrammaticalGender.feminine;
    if (word == 'Haus') return GrammaticalGender.neuter;
    return GrammaticalGender.none;
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    return GrammaticalCategory.noun;
  }

  @override
  bool isValidArticle(String word, String article) => true;

  @override
  GrammaticalCase? determineCase(String word, {String? context}) {
    if (word == 'Hund') return GrammaticalCase.nominative;
    return GrammaticalCase.none;
  }
}

class MockSwahiliProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'sw';

  @override
  GrammarCapabilityProfile get capabilityProfile => const GrammarCapabilityProfile(
    hasNounClasses: true,
  );

  @override
  GrammaticalGender determineGender(String word, {String? article}) => GrammaticalGender.none;

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) => GrammaticalCategory.noun;

  @override
  bool isValidArticle(String word, String article) => true;

  @override
  String? determineNounClass(String word) {
    if (word == 'mtu') return 'M-WA';
    return null;
  }
}

class MockMissingProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'en';

  @override
  GrammarCapabilityProfile get capabilityProfile => const GrammarCapabilityProfile();

  @override
  GrammaticalGender determineGender(String word, {String? article}) => GrammaticalGender.none;

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) => GrammaticalCategory.unknown;

  @override
  bool isValidArticle(String word, String article) => true;
}

void main() {
  testWidgets('German presentation applies correct colors and labels', (tester) async {
    final engine = SemanticPresentationEngine(
      ruleProvider: MockDeProvider(),
      packVersion: 'v1',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SemanticWordText(
          word: 'Hund',
          engine: engine,
        ),
      ),
    ));

    final semantics = tester.getSemantics(find.byType(SemanticWordText));
    expect(semantics.label, contains('Masculine'));
    expect(semantics.label, contains('noun'));
    expect(semantics.label, contains('nominative'));

    final text = tester.widget<Text>(find.text('Hund'));
    expect(text.style?.color, AppColors.articleDer);
  });

  testWidgets('Swahili presentation applies noun classes', (tester) async {
    final engine = SemanticPresentationEngine(
      ruleProvider: MockSwahiliProvider(),
      packVersion: 'v1',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SemanticWordText(
          word: 'mtu',
          engine: engine,
        ),
      ),
    ));

    final semantics = tester.getSemantics(find.byType(SemanticWordText));
    expect(semantics.label, contains('Class M-WA'));

    final text = tester.widget<Text>(find.text('mtu'));
    expect(text.style?.color, isNotNull);
  });

  testWidgets('Missing metadata falls back gracefully', (tester) async {
    final engine = SemanticPresentationEngine(
      ruleProvider: MockMissingProvider(),
      packVersion: 'v1',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SemanticWordText(
          word: 'book',
          engine: engine,
        ),
      ),
    ));

    final semantics = tester.getSemantics(find.byType(SemanticWordText));
    expect(semantics.label, contains('book'));

    final text = tester.widget<Text>(find.text('book'));
    expect(text.style?.color, isNull); // Falls back to uncolored text, null
  });
}
