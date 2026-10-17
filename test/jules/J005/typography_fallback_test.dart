import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';
import 'package:deutsch_bilarabi/design_system/font_fallback_engine.dart';

void main() {
  group('AppTypography and FontFallbackEngine Tests', () {
    test('FontFallbackEngine universal fallback contains all supported scripts', () {
      final fallbacks = FontFallbackEngine.universalFallback;
      expect(fallbacks, contains('NotoSansArabic'));
      expect(fallbacks, contains('NotoSansHebrew'));
      expect(fallbacks, contains('NotoSansDevanagari'));
      expect(fallbacks, contains('NotoSansEthiopic'));
      expect(fallbacks, contains('NotoSansGeorgian'));
      expect(fallbacks, contains('NotoSansArmenian'));
      expect(fallbacks, contains('NotoSansSC'));
    });

    test('FontFallbackEngine getFallbackForText targets specific scripts', () {
      expect(FontFallbackEngine.getFallbackForText('مرحبا'), contains('NotoSansArabic'));
      expect(FontFallbackEngine.getFallbackForText('שלום'), contains('NotoSansHebrew'));
      expect(FontFallbackEngine.getFallbackForText('नमस्ते'), contains('NotoSansDevanagari')); // combining marks
      expect(FontFallbackEngine.getFallbackForText('ሰላም'), contains('NotoSansEthiopic'));
      expect(FontFallbackEngine.getFallbackForText('გამარჯობა'), contains('NotoSansGeorgian'));
      expect(FontFallbackEngine.getFallbackForText('Բարև'), contains('NotoSansArmenian'));
      expect(FontFallbackEngine.getFallbackForText('你好'), contains('NotoSansSC'));

      // Mixed script
      final mixed = FontFallbackEngine.getFallbackForText('Hello مرحبا 你好');
      expect(mixed, contains('NotoSansArabic'));
      expect(mixed, contains('NotoSansSC'));
    });

    test('AppTypography applies default font and fallback list', () {
      final style = AppTypography.body;
      expect(style.fontFamily, 'Cairo');
      expect(style.fontFamilyFallback, isNotEmpty);
      expect(style.fontFamilyFallback, contains('NotoSansArabic'));
    });

    testWidgets('Renders mixed script text successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('مرحبا (Hello) 你好', style: AppTypography.display),
                Text('שלום (Peace)', style: AppTypography.h1, textDirection: TextDirection.rtl),
                Text('नमस्ते', style: AppTypography.body), // Devangari with combining marks
                Text('This is purely English text.', style: AppTypography.body),
                // Extremely long string to test wrapping logic with mixed script
                Text('English ' * 20 + 'مرحبا ' * 20 + '你好 ' * 20, style: AppTypography.body),
              ],
            ),
          ),
        ),
      );

      // Verify that the text renders without layout errors.
      expect(find.text('مرحبا (Hello) 你好'), findsOneWidget);
      expect(find.text('שלום (Peace)'), findsOneWidget);
      expect(find.text('नमस्ते'), findsOneWidget);
    });

    testWidgets('Layout does not crash on narrow viewports with large mixed text', (WidgetTester tester) async {
      // Set narrow constraints
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 150, // narrow width
                child: Text(
                  'A very long text mixing scripts: გამარჯობა (Georgian), Բարև (Armenian), ሰላም (Ethiopic). '
                  'This should wrap naturally without crashing.',
                  style: AppTypography.body,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });
}
