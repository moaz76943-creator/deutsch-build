import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/semantic_color_tagging/semantic_presentation_engine.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';

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
    // Return unknown to simulate no category unless we mock it.
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
  group('SemanticPresentationEngine Tests (J054)', () {
    test('German colors are derived from AppColors.article* specific colors', () {
      final mockDe = MockGrammarProvider(
        languageCode: 'de',
        determineGenderMock: (word, {article}) {
          if (word == 'Hund') return GrammaticalGender.masculine;
          if (word == 'Freiheit') return GrammaticalGender.feminine;
          if (word == 'Mädchen') return GrammaticalGender.neuter;
          return GrammaticalGender.none;
        },
      );

      final engine = SemanticPresentationEngine(ruleProvider: mockDe, packVersion: 'v1');

      expect(engine.getPresentationForWord('Hund').color, AppColors.articleDer);
      expect(engine.getPresentationForWord('Freiheit').color, AppColors.articleDie);
      expect(engine.getPresentationForWord('Mädchen').color, AppColors.articleDas);

      // Unbekannt has no gender and no category -> color should be null for uncolored degradation
      expect(engine.getPresentationForWord('Unbekannt').color, isNull);
    });

    test('Non-German colors use standard primary/secondary/tertiary colors', () {
      final mockFr = MockGrammarProvider(
        languageCode: 'fr',
        determineGenderMock: (word, {article}) {
          if (word == 'chien') return GrammaticalGender.masculine;
          if (word == 'liberté') return GrammaticalGender.feminine;
          if (word == 'neuter_word') return GrammaticalGender.neuter;
          return GrammaticalGender.none;
        },
      );

      final engine = SemanticPresentationEngine(ruleProvider: mockFr, packVersion: 'v1');

      expect(engine.getPresentationForWord('chien').color, AppColors.primary);
      expect(engine.getPresentationForWord('liberté').color, AppColors.secondary);
      expect(engine.getPresentationForWord('neuter_word').color, AppColors.tertiary);

      // inconnu has no gender and no category -> color should be null
      expect(engine.getPresentationForWord('inconnu').color, isNull);
    });

    test('Cache behaves correctly per instance', () {
       final mockFr1 = MockGrammarProvider(
        languageCode: 'fr',
        determineGenderMock: (word, {article}) => GrammaticalGender.masculine,
      );

      final engine1 = SemanticPresentationEngine(ruleProvider: mockFr1, packVersion: 'v1');

      final m1 = engine1.getPresentationForWord('test');
      final m1Cached = engine1.getPresentationForWord('test');

      expect(m1.color, AppColors.primary);

      // Ensure the same engine returns the exact identical cached object.
      expect(identical(m1, m1Cached), isTrue);
    });
  });

  group('SemanticWordText Widget Tests', () {
    testWidgets('RTL layout and accessibility label are present', (WidgetTester tester) async {
      final mockAr = MockGrammarProvider(
        languageCode: 'ar',
        determineGenderMock: (word, {article}) => GrammaticalGender.feminine,
      );
      final engine = SemanticPresentationEngine(ruleProvider: mockAr, packVersion: 'v1');
      const word = 'شمس';

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
          home: Scaffold(
            body: SemanticWordText(
              word: word,
              engine: engine,
            ),
          ),
        ),
      );

      final textFinder = find.text('شمس');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, AppColors.secondary);

      final semanticsFinder = find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label == 'Feminine');
      expect(semanticsFinder, findsOneWidget);
    });
  });
}
