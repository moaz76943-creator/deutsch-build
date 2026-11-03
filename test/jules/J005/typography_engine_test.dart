import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/design_system/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography Fallback Engine', () {
    test('identifies Arabic fallbacks correctly (Cairo)', () {
      final text = 'مرحبا بك';
      final fallbacks = MultiScriptTypography.getFallbacksForText(text);
      expect(fallbacks, contains(MultiScriptTypography.arabicFallback));
      expect(fallbacks, contains('Cairo'));
    });

    test('identifies Hebrew fallbacks correctly', () {
      final text = 'שלום';
      final fallbacks = MultiScriptTypography.getFallbacksForText(text);
      expect(fallbacks, contains(MultiScriptTypography.hebrewFallback));
    });

    test('identifies Devanagari fallbacks correctly', () {
      final text = 'नमस्ते';
      final fallbacks = MultiScriptTypography.getFallbacksForText(text);
      expect(fallbacks, contains(MultiScriptTypography.devanagariFallback));
    });

    test('identifies CJK fallbacks correctly', () {
      final textSC = '你好';
      final fallbacksSC = MultiScriptTypography.getFallbacksForText(textSC);
      expect(fallbacksSC, contains(MultiScriptTypography.scFallback));

      final textJP = 'こんにちは';
      final fallbacksJP = MultiScriptTypography.getFallbacksForText(textJP);
      expect(fallbacksJP, contains(MultiScriptTypography.jpFallback));

      final textKR = '안녕하세요';
      final fallbacksKR = MultiScriptTypography.getFallbacksForText(textKR);
      expect(fallbacksKR, contains(MultiScriptTypography.krFallback));
    });

    test('identifies mixed scripts correctly', () {
      final text = 'Hello مرحبا こんにちは';
      final fallbacks = MultiScriptTypography.getFallbacksForText(text);
      expect(fallbacks, contains(MultiScriptTypography.arabicFallback));
      expect(fallbacks, contains(MultiScriptTypography.jpFallback));
      expect(fallbacks.length, 3); // Cairo, Arabic and JP, standard text needs no explicit fallback here
    });

    test('returns empty fallbacks for pure Latin text', () {
      final text = 'Hello world 123!';
      final fallbacks = MultiScriptTypography.getFallbacksForText(text);
      expect(fallbacks, isEmpty);
    });
  });

  group('ScriptAwareText Widget', () {
    testWidgets('renders simple text without fallbacks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScriptAwareText('Hello world'),
          ),
        ),
      );

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontFamilyFallback, null);
    });

    testWidgets('injects correct fontFamilyFallback for mixed text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScriptAwareText('Hello مرحبا こんにちは', style: TextStyle(fontSize: 16)),
          ),
        ),
      );

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      final fallbacks = textWidget.style?.fontFamilyFallback;

      expect(fallbacks, isNotNull);
      expect(fallbacks, contains(MultiScriptTypography.arabicFallback));
      expect(fallbacks, contains(MultiScriptTypography.jpFallback));
    });

    testWidgets('supports rich text spans', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScriptAwareText.rich(
              TextSpan(
                text: 'Hello ',
                children: [
                  TextSpan(text: 'مرحبا'),
                ]
              )
            ),
          ),
        ),
      );

      final textFinder = find.byType(RichText);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<RichText>(textFinder);
      final fallbacks = textWidget.text.style?.fontFamilyFallback;

      expect(fallbacks, isNotNull);
      expect(fallbacks, contains(MultiScriptTypography.arabicFallback));
    });

    testWidgets('preserves explicitly passed existing fallbacks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScriptAwareText(
              'שלום',
              style: TextStyle(fontFamilyFallback: ['ExistingFallback']),
            ),
          ),
        ),
      );

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      final fallbacks = textWidget.style?.fontFamilyFallback;

      expect(fallbacks, isNotNull);
      expect(fallbacks!.first, 'ExistingFallback');
      expect(fallbacks, contains(MultiScriptTypography.hebrewFallback));
    });

    testWidgets('preserves textDirection and layout properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScriptAwareText(
              'مرحبا',
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.textDirection, TextDirection.rtl);
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.textAlign, TextAlign.center);
    });
  });
}
