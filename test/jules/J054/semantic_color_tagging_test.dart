import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/semantic_color_tagging/semantic_presentation_engine.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';

class MockGrammarProvider implements LanguageGrammarRuleProvider {
  @override
  final String languageCode;

  final GrammaticalGender Function(String word, {String? article}) determineGenderMock;
  final GrammaticalCategory Function(String word, {String? article})? determineCategoryMock;

  @override
  final GrammarCapabilityProfile capabilityProfile;

  MockGrammarProvider({
    required this.languageCode,
    required this.determineGenderMock,
    this.determineCategoryMock,
    this.capabilityProfile = const GrammarCapabilityProfile(),
  });

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    return determineCategoryMock?.call(word, article: article) ?? GrammaticalCategory.unknown;
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
  Aspect? determineAspect(String word) {
    return capabilityProfile.hasAspect ? Aspect.unknown : null;
  }

  @override
  GrammaticalCase? determineCase(String word, {String? context}) {
    return capabilityProfile.hasCases ? GrammaticalCase.unknown : null;
  }

  @override
  Mood? determineMood(String word) {
    return capabilityProfile.hasMood ? Mood.unknown : null;
  }

  @override
  String? determineNounClass(String word) {
    return capabilityProfile.hasNounClasses ? 'test_class' : null;
  }

  @override
  GrammaticalNumber? determineNumber(String word) {
    return capabilityProfile.hasNumber ? GrammaticalNumber.singular : null;
  }

  @override
  GrammaticalPerson? determinePerson(String word) {
    return capabilityProfile.hasPerson ? GrammaticalPerson.first : null;
  }

  @override
  Tense? determineTense(String word) {
    return capabilityProfile.hasTense ? Tense.past : null;
  }

  @override
  List<String>? extractAffixes(String word) {
    return null;
  }

  @override
  String? extractPattern(String word) {
    return null;
  }

  @override
  String? extractRoot(String word) {
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
        determineCategoryMock: (word, {article}) {
          if (word == 'Unbekannt') return GrammaticalCategory.noun;
          return GrammaticalCategory.unknown;
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
      // 'inconnu' has GrammaticalGender.none AND GrammaticalCategory.unknown -> should be null
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

    test('Capabilities are evaluated dynamically without exceptions', () {
       final mockFull = MockGrammarProvider(
        languageCode: 'sw', // Swahili - noun classes, agglutinative, etc.
        determineGenderMock: (word, {article}) => GrammaticalGender.none,
        determineCategoryMock: (word, {article}) => GrammaticalCategory.noun,
        capabilityProfile: const GrammarCapabilityProfile(
          hasNounClasses: true,
          hasNumber: true,
          hasPerson: true,
          hasTense: true,
          isAgglutinative: true,
        ),
      );

      final engine = SemanticPresentationEngine(ruleProvider: mockFull, packVersion: 'v1');
      final m1 = engine.getPresentationForWord('kitabu');

      expect(m1.color, AppColors.articleOther);
      expect(m1.label, contains('noun'));
      expect(m1.label, contains('Class test_class'));
      expect(m1.label, contains('singular'));
      expect(m1.label, contains('first person'));
      expect(m1.label, contains('past'));
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
          theme: ThemeData.light(),
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

    testWidgets('Dark mode switches color correctly', (WidgetTester tester) async {
      final mockAr = MockGrammarProvider(
        languageCode: 'ar',
        determineGenderMock: (word, {article}) => GrammaticalGender.masculine,
      );
      final engine = SemanticPresentationEngine(ruleProvider: mockAr, packVersion: 'v1');
      const word = 'قمر';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SemanticWordText(
              word: word,
              engine: engine,
            ),
          ),
        ),
      );

      final textFinder = find.text('قمر');
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, AppColors.primaryDark);
    });

    testWidgets('Missing grammar degrades to uncolored text and no Semantics', (WidgetTester tester) async {
      final mockAr = MockGrammarProvider(
        languageCode: 'ar',
        determineGenderMock: (word, {article}) => GrammaticalGender.none,
      );
      final engine = SemanticPresentationEngine(ruleProvider: mockAr, packVersion: 'v1');
      const word = 'هل';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticWordText(
              word: word,
              engine: engine,
            ),
          ),
        ),
      );

      final textFinder = find.text('هل');
      final textWidget = tester.widget<Text>(textFinder);

      // Inherits uncolored (or theme default) if color is null.
      // The style map has null color, meaning it falls back naturally.
      // the baseStyle ?? AppTypography.body has a color, but withColor(null) might keep it,
      // let's verify what happens to the color property:
      expect(textWidget.style?.color, isNull);

      final semanticsFinder = find.descendant(of: find.byType(SemanticWordText), matching: find.byType(Semantics));
      expect(semanticsFinder, findsNothing);
    });
  });
}
