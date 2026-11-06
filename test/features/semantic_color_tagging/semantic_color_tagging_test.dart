import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/semantic_color_tagging/semantic_color_tagging.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';

class MockGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  final String languageCode;

  final GrammaticalGender Function(String word, {String? article}) determineGenderMock;

  MockGrammarProvider({
    required this.languageCode,
    required this.determineGenderMock,
  });

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    return GrammaticalCategory.unknown;
  }

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    return determineGenderMock(word, article: article);
  }

  @override
  bool isValidArticle(String word, String article) {
    return false;
  }
}

void main() {
  group('SemanticColorTagging Tests', () {
    test('getColorForWord returns Colors.blue.shade600 for masculine gender', () {
      final mockProvider = MockGrammarProvider(
        languageCode: 'test',
        determineGenderMock: (word, {article}) => GrammaticalGender.masculine,
      );
      final tagging = SemanticColorTagging(ruleProvider: mockProvider);

      expect(tagging.getColorForWord('testWord'), Colors.blue.shade600);
    });

    test('getColorForWord returns Colors.red.shade600 for feminine gender', () {
      final mockProvider = MockGrammarProvider(
        languageCode: 'test',
        determineGenderMock: (word, {article}) => GrammaticalGender.feminine,
      );
      final tagging = SemanticColorTagging(ruleProvider: mockProvider);

      expect(tagging.getColorForWord('testWord'), Colors.red.shade600);
    });

    test('getColorForWord returns Colors.green.shade600 for neuter gender', () {
      final mockProvider = MockGrammarProvider(
        languageCode: 'test',
        determineGenderMock: (word, {article}) => GrammaticalGender.neuter,
      );
      final tagging = SemanticColorTagging(ruleProvider: mockProvider);

      expect(tagging.getColorForWord('testWord'), Colors.green.shade600);
    });

    test('getColorForWord returns Colors.grey.shade700 for common gender', () {
      final mockProvider = MockGrammarProvider(
        languageCode: 'test',
        determineGenderMock: (word, {article}) => GrammaticalGender.common,
      );
      final tagging = SemanticColorTagging(ruleProvider: mockProvider);

      expect(tagging.getColorForWord('testWord'), Colors.grey.shade700);
    });

    test('getColorForWord returns Colors.grey.shade700 for none gender', () {
      final mockProvider = MockGrammarProvider(
        languageCode: 'test',
        determineGenderMock: (word, {article}) => GrammaticalGender.none,
      );
      final tagging = SemanticColorTagging(ruleProvider: mockProvider);

      expect(tagging.getColorForWord('testWord'), Colors.grey.shade700);
    });
  });
}
