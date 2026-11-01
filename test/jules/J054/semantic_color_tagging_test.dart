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
  GrammarCapabilityProfile get capabilityProfile => const GrammarCapabilityProfile(hasGender: true);

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

class MockVersionedProvider extends LanguageGrammarRuleProvider {
  @override
  final String languageCode = 'en';

  @override
  GrammarCapabilityProfile get capabilityProfile => const GrammarCapabilityProfile(
    hasGender: true,
    hasCases: true,
    hasNumber: true,
  );

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    return GrammaticalCategory.noun;
  }

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    return GrammaticalGender.masculine;
  }

  @override
  GrammaticalCase? determineCase(String word, {String? context}) {
    return GrammaticalCase.nominative;
  }

  @override
  GrammaticalNumber? determineNumber(String word) {
    return GrammaticalNumber.singular;
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
      expect(engine.getPresentationForWord('Unbekannt').color, AppColors.articleOther);
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
      expect(engine.getPresentationForWord('inconnu').color, AppColors.articleOther);
    });

    test('Cache behaves correctly per instance and qualifies by pack version', () {
      final mockProvider = MockVersionedProvider();

      final engine1 = SemanticPresentationEngine(ruleProvider: mockProvider, packVersion: 'v1');
      final engine2 = SemanticPresentationEngine(ruleProvider: mockProvider, packVersion: 'v2');

      final m1 = engine1.getPresentationForWord('test');
      final m1Cached = engine1.getPresentationForWord('test');

      // Should be identical within the same engine instance
      expect(identical(m1, m1Cached), isTrue);

      final m2 = engine2.getPresentationForWord('test');
      // Across different engines (and versions), it should be recomputed and NOT identical
      expect(identical(m1, m2), isFalse);
    });

    test('Labels correctly include determined capabilities if present', () {
       final mockProvider = MockVersionedProvider();
       final engine = SemanticPresentationEngine(ruleProvider: mockProvider, packVersion: 'v1');

       final presentation = engine.getPresentationForWord('test');
       expect(presentation.label, 'Masculine noun nominative singular');
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
