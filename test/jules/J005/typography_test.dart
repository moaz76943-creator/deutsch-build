import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/font_fallback_engine.dart';
import 'package:deutsch_bilarabi/design_system/multi_script_typography.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';
import 'package:deutsch_bilarabi/core/text/language_identity.dart';

void main() {
  group('FontFallbackEngine Tests', () {
    test('Empty text returns empty fallbacks', () {
      final fallbacks = FontFallbackEngine.getFallbackForText('');
      expect(fallbacks, isEmpty);
    });

    test('Latin text returns empty fallbacks', () {
      final fallbacks = FontFallbackEngine.getFallbackForText('Hello World');
      expect(fallbacks, isEmpty);
    });

    test('Arabic text returns Cairo', () {
      final fallbacks = FontFallbackEngine.getFallbackForText('مرحبا بكم');
      expect(fallbacks, contains('Cairo'));
    });

    test('Mixed script text returns multiple fallbacks', () {
      final fallbacks = FontFallbackEngine.getFallbackForText('مرحبا שלום 您好');
      expect(fallbacks, containsAll(['Cairo', 'NotoSansHebrew', 'NotoSansSC']));
    });
  });

  group('MultiScriptTypography Tests', () {
    test('Arabic text identifies Cairo', () {
      final fallbacks = MultiScriptTypography.getFallbacksForText('مرحبا بكم');
      expect(fallbacks, contains('Cairo'));
    });

    test('Hebrew text identifies NotoSansHebrew', () {
      final fallbacks = MultiScriptTypography.getFallbacksForText('שלום');
      expect(fallbacks, contains('NotoSansHebrew'));
    });

    testWidgets('ScriptAwareText renders correctly with fallbacks', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScriptAwareText('مرحبا שלום'),
          ),
        ),
      );

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder);

      expect(textWidget.style?.fontFamilyFallback, containsAll(['Cairo', 'NotoSansHebrew']));
    });

    testWidgets('ScriptAwareText handles long texts and maxLines', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: ScriptAwareText(
                'This is a very long text that will overflow when placed in a narrow viewport. مرحبا بكم',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder);

      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.style?.fontFamilyFallback, contains('Cairo'));
    });
  });

  group('AppTypography Tests', () {
    test('getSafeStyle uses correct font family for cairo profile', () {
      const identity = LanguageIdentity(
        languageCode: 'ar',
        writingDirection: WritingDirection.rtl,
        typographyProfile: 'cairo',
        tokenizerProfile: 'default',
        normalizationProfile: 'default',
      );

      final style = AppTypography.getSafeStyle(identity);
      expect(style.fontFamily, 'Cairo');
      expect(style.fontFamilyFallback, contains('Cairo'));
      expect(style.height, 1.45);
    });

    testWidgets('buildBiDiText sets correct directionality for RTL', (WidgetTester tester) async {
      const identity = LanguageIdentity(
        languageCode: 'ar',
        writingDirection: WritingDirection.rtl,
        typographyProfile: 'cairo',
        tokenizerProfile: 'default',
        normalizationProfile: 'default',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTypography.buildBiDiText('مرحبا بكم', identity),
          ),
        ),
      );

      final directionalityFinder = find.descendant(
        of: find.byType(Scaffold),
        matching: find.byType(Directionality),
      ).first;

      expect(directionalityFinder, findsWidgets);

      final textFinder = find.byType(Text);
      expect(textFinder, findsWidgets);
      final textWidget = tester.widget<Text>(textFinder.first);
      expect(textWidget.textAlign, TextAlign.right);
    });

    testWidgets('buildBiDiText sets correct directionality for LTR', (WidgetTester tester) async {
      const identity = LanguageIdentity(
        languageCode: 'de',
        writingDirection: WritingDirection.ltr,
        typographyProfile: 'default',
        tokenizerProfile: 'default',
        normalizationProfile: 'default',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTypography.buildBiDiText('Hallo Welt', identity),
          ),
        ),
      );

      final textFinder = find.byType(Text);
      expect(textFinder, findsWidgets);
      final textWidget = tester.widget<Text>(textFinder.first);
      expect(textWidget.textAlign, TextAlign.left);
    });
  });
}
