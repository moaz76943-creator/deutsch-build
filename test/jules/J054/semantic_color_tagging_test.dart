import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/semantic_color_tagging/semantic_presentation_engine.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';

class MockGrammarProvider extends LanguageGrammarRuleProvider {
  @override
  final String languageCode;

  final GrammaticalGender Function(String word, {String? article}) determineGenderMock;
  final String? Function(String word)? determineNounClassMock;
  final Aspect? Function(String word)? determineAspectMock;
  final Mood? Function(String word)? determineMoodMock;

  final GrammarCapabilityProfile capabilityProfileMock;

  @override
  GrammarCapabilityProfile get capabilityProfile => capabilityProfileMock;

  MockGrammarProvider({
    required this.languageCode,
    required this.determineGenderMock,
    this.determineNounClassMock,
    this.determineAspectMock,
    this.determineMoodMock,
    this.capabilityProfileMock = const GrammarCapabilityProfile(hasGender: true),
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

  @override
  String? determineNounClass(String word) {
    if (determineNounClassMock != null) return determineNounClassMock!(word);
    return null;
  }

  @override
  Aspect? determineAspect(String word) {
    if (determineAspectMock != null) return determineAspectMock!(word);
    return null;
  }

  @override
  Mood? determineMood(String word) {
    if (determineMoodMock != null) return determineMoodMock!(word);
    return null;
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

    test('Missing data degrades to uncolored and empty label if nothing else matches', () {
      final mock = MockGrammarProvider(
        languageCode: 'en',
        determineGenderMock: (word, {article}) => GrammaticalGender.none,
        capabilityProfileMock: const GrammarCapabilityProfile(hasGender: false),
      );

      final engine = SemanticPresentationEngine(ruleProvider: mock, packVersion: 'v1');
      final presentation = engine.getPresentationForWord('apple');

      expect(presentation.color, isNull);
      expect(presentation.label, isEmpty);
    });

    test('Unsupported grammatical categories never appear as facts', () {
      final mock = MockGrammarProvider(
        languageCode: 'en',
        determineGenderMock: (word, {article}) => GrammaticalGender.masculine,
        // Since capabilityProfile says hasGender is false, it shouldn't show it!
        capabilityProfileMock: const GrammarCapabilityProfile(hasGender: false, hasAspect: false),
        determineAspectMock: (word) => Aspect.perfective,
      );

      final engine = SemanticPresentationEngine(ruleProvider: mock, packVersion: 'v1');
      final presentation = engine.getPresentationForWord('apple');

      // Gender is skipped because capability is false
      // Aspect is skipped because capability is false
      expect(presentation.color, isNull);
      expect(presentation.label, isEmpty);
    });

    test('Support other gender and noun-class systems when attested', () {
      final mockSw = MockGrammarProvider(
        languageCode: 'sw',
        determineGenderMock: (word, {article}) => GrammaticalGender.none,
        determineNounClassMock: (word) => 'Ki/Vi',
        capabilityProfileMock: const GrammarCapabilityProfile(hasNounClasses: true),
      );

      final engine = SemanticPresentationEngine(ruleProvider: mockSw, packVersion: 'v1');
      final presentation = engine.getPresentationForWord('kitabu');

      expect(presentation.color, AppColors.articleOther);
      expect(presentation.label, 'Noun Class Ki/Vi');
    });

    test('Recompute presentation when the admitted pack version changes', () {
      final mockFr1 = MockGrammarProvider(
        languageCode: 'fr',
        determineGenderMock: (word, {article}) => GrammaticalGender.masculine,
      );

      final engine1 = SemanticPresentationEngine(ruleProvider: mockFr1, packVersion: 'v1');
      final m1 = engine1.getPresentationForWord('test');

      final engine2 = SemanticPresentationEngine(ruleProvider: mockFr1, packVersion: 'v2');
      final m2 = engine2.getPresentationForWord('test');

      // It should NOT be the exact same object because the cache key should differ based on packVersion
      expect(identical(m1, m2), isFalse);
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
