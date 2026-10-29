import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';

void main() {
  group('J005 Multi-Script Typography & Noto Fallback Engine', () {
    testWidgets('AppTypography contains fallback lists', (WidgetTester tester) async {
      expect(AppTypography.fallbackFontFamilies, isNotEmpty);
      expect(AppTypography.fallbackFontFamilies, contains('Noto Sans Arabic'));
      expect(AppTypography.fallbackFontFamilies, contains('Noto Sans SC'));
    });

    testWidgets('Text styles use fontFamilyFallback correctly', (WidgetTester tester) async {
      expect(AppTypography.body.fontFamilyFallback, AppTypography.fallbackFontFamilies);
      expect(AppTypography.display.fontFamilyFallback, AppTypography.fallbackFontFamilies);
      expect(AppTypography.title.fontFamilyFallback, AppTypography.fallbackFontFamilies);
    });

    testWidgets('Mixed-script rendering with Directionality (Arabic/English)', (WidgetTester tester) async {
      const mixedText = 'مرحبا World';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                mixedText,
                style: AppTypography.body,
              ),
            ),
          ),
        ),
      );

      final textFinder = find.text(mixedText);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget(textFinder);
      expect(textWidget.style?.fontFamilyFallback, isNotNull);
      expect(textWidget.style?.fontFamilyFallback, contains('Noto Sans Arabic'));
      expect(textWidget.style?.fontFamily, 'Cairo');
    });

    testWidgets('CJK rendering (Noto Sans SC fallback)', (WidgetTester tester) async {
      const cjkText = '你好，世界';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                cjkText,
                style: AppTypography.title,
              ),
            ),
          ),
        ),
      );

      final textFinder = find.text(cjkText);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget(textFinder);
      expect(textWidget.style?.fontFamilyFallback, contains('Noto Sans SC'));
    });

    testWidgets('Devanagari rendering with Combining Marks', (WidgetTester tester) async {
      const devanagariText = 'नमस्ते';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                devanagariText,
                style: AppTypography.h1,
              ),
            ),
          ),
        ),
      );

      final textFinder = find.text(devanagariText);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget(textFinder);
      expect(textWidget.style?.fontFamilyFallback, contains('Noto Sans Devanagari'));
    });
  });
}
