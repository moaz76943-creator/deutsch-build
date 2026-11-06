import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/semantic_color_tagging/semantic_color_tagging.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';

class MockRuleProvider extends LanguageGrammarRuleProvider {
  @override
  String get languageCode => 'de';

  final Map<String, GrammaticalGender> wordGenders;

  MockRuleProvider(this.wordGenders);

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    return wordGenders[word] ?? GrammaticalGender.none;
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    return GrammaticalCategory.unknown;
  }

  @override
  bool isValidArticle(String word, String article) {
    return true;
  }
}

void main() {
  group('SemanticColorTagging', () {
    late MockRuleProvider mockRuleProvider;
    late SemanticColorTagging semanticColorTagging;

    setUp(() {
      mockRuleProvider = MockRuleProvider({
        'der': GrammaticalGender.masculine,
        'die': GrammaticalGender.feminine,
        'das': GrammaticalGender.neuter,
        'common': GrammaticalGender.common,
        'none': GrammaticalGender.none,
      });
      // ignore: deprecated_member_use_from_same_package
      semanticColorTagging = SemanticColorTagging(ruleProvider: mockRuleProvider);
    });

    test('getColorForWord returns blue for masculine', () {
      expect(semanticColorTagging.getColorForWord('der'), Colors.blue.shade600);
    });

    test('getColorForWord returns red for feminine', () {
      expect(semanticColorTagging.getColorForWord('die'), Colors.red.shade600);
    });

    test('getColorForWord returns green for neuter', () {
      expect(semanticColorTagging.getColorForWord('das'), Colors.green.shade600);
    });

    test('getColorForWord returns grey for common', () {
      expect(semanticColorTagging.getColorForWord('common'), Colors.grey.shade700);
    });

    test('getColorForWord returns grey for none', () {
      expect(semanticColorTagging.getColorForWord('none'), Colors.grey.shade700);
    });
  });
}
