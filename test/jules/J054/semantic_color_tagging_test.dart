import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/features/semantic_color_tagging/semantic_presentation_engine.dart';

class FakeRules extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'de';
  @override
  GrammaticalGender determineGender(String word, {String? article}) =>
      GrammaticalGender.masculine;
  @override
  GrammaticalCategory determineCategory(String word, {String? article}) =>
      GrammaticalCategory.noun;
  @override
  bool isValidArticle(String word, String article) => article == 'der';
}

class BrokenRules extends FakeRules {
  @override
  GrammaticalGender determineGender(String word, {String? article}) =>
      throw StateError('local pack unavailable');
}

void main() {
  test('unverified guesses are not presented as linguistic facts', () {
    final engine = SemanticPresentationEngine(
      ruleProvider: FakeRules(), packVersion: 'v1',
    );
    final status = engine.getPresentationForWord('Baum', article: 'der');
    expect(status.isAttested, isFalse);
    expect(status.label, contains('not verified'));
  });

  test('explicitly admitted language metadata and cache isolation', () {
    final engine = SemanticPresentationEngine(
      ruleProvider: FakeRules(), packVersion: 'v1',
      maxCacheEntries: 2,
      isAdmittedEvidence: (word, article) => word == 'Baum',
    );
    final verified = engine.getPresentationForWord('Baum', article: 'der');
    expect(verified.isAttested, isTrue);
    expect(verified.label, contains('Masculine'));
    expect(engine.getPresentationForWord('Baum', article: 'das').isAttested, isTrue);
    engine.getPresentationForWord('Haus');
    expect(engine.cacheSize, 2);
    engine.clear();
    expect(engine.cacheSize, 0);
  });

  testWidgets('mixed-direction words use explicit text direction', (tester) async {
    final engine = SemanticPresentationEngine(
      ruleProvider: FakeRules(), packVersion: 'v1',
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SemanticWordText(
          word: 'كتاب English',
          engine: engine,
          textDirection: TextDirection.rtl,
        ),
      ),
    ));
    final rendered = tester.widget<Text>(find.text('كتاب English'));
    expect(rendered.textDirection, TextDirection.rtl);
  });

  test('reject zero-size cache and missing revision', () {
    expect(
      () => SemanticPresentationEngine(
        ruleProvider: FakeRules(), packVersion: '',
      ),
      throwsArgumentError,
    );
  });
  test('offline reader exceptions and oversized cache inputs fail closed', () {
    final engine = SemanticPresentationEngine(
      ruleProvider: BrokenRules(),
      packVersion: 'v1',
      isAdmittedEvidence: (word, article) => true,
    );
    final status = engine.getPresentationForWord('broken');
    expect(status.isAttested, isFalse);
    expect(status.label, 'Grammar not verified');
    expect(
      engine.getPresentationForWord(List<String>.filled(600, 'x').join())
          .isAttested,
      isFalse,
    );
    expect(engine.cacheSize, 1);
  });

}
