import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:deutsch_bilarabi/features/semantic_color_tagging/semantic_color_tagging.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';

class MockLanguageGrammarRuleProvider extends Mock
    implements LanguageGrammarRuleProvider {}

void main() {
  late SemanticColorTagging tagging;
  late MockLanguageGrammarRuleProvider mockProvider;

  setUp(() {
    mockProvider = MockLanguageGrammarRuleProvider();
    tagging = SemanticColorTagging(ruleProvider: mockProvider);
  });

  group('SemanticColorTagging getColorForWord', () {
    test('returns blue.shade600 for masculine gender', () {
      when(() => mockProvider.determineGender('Mann', article: 'der'))
          .thenReturn(GrammaticalGender.masculine);

      final color = tagging.getColorForWord('Mann', article: 'der');

      expect(color, equals(Colors.blue.shade600));
    });

    test('returns red.shade600 for feminine gender', () {
      when(() => mockProvider.determineGender('Frau', article: 'die'))
          .thenReturn(GrammaticalGender.feminine);

      final color = tagging.getColorForWord('Frau', article: 'die');

      expect(color, equals(Colors.red.shade600));
    });

    test('returns green.shade600 for neuter gender', () {
      when(() => mockProvider.determineGender('Kind', article: 'das'))
          .thenReturn(GrammaticalGender.neuter);

      final color = tagging.getColorForWord('Kind', article: 'das');

      expect(color, equals(Colors.green.shade600));
    });

    test('returns grey.shade700 for common gender', () {
      when(() => mockProvider.determineGender('Person', article: 'en'))
          .thenReturn(GrammaticalGender.common);

      final color = tagging.getColorForWord('Person', article: 'en');

      expect(color, equals(Colors.grey.shade700));
    });

    test('returns grey.shade700 for none gender', () {
      when(() => mockProvider.determineGender('läuft', article: null))
          .thenReturn(GrammaticalGender.none);

      final color = tagging.getColorForWord('läuft');

      expect(color, equals(Colors.grey.shade700));
    });
  });
}
