import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/design_system/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography Font Fallback Tests', () {
    test('Injects canonical fallback stack containing Arabic, CJK, and Devanagari fonts', () {
      final style = MultiScriptTypography.createTextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      );

      expect(style.fontFamilyFallback, isNotNull);
      expect(style.fontFamilyFallback!.contains('Noto Sans Arabic'), isTrue);
      expect(style.fontFamilyFallback!.contains('Noto Sans JP'), isTrue);
      expect(style.fontFamilyFallback!.contains('Noto Sans Devanagari'), isTrue);
    });

    test('Applies font fallback chain across TextTheme hierarchy without null errors', () {
      const baseTheme = TextTheme(
        bodyMedium: TextStyle(fontSize: 14.0),
        titleLarge: TextStyle(fontSize: 20.0),
      );

      final enhancedTheme = MultiScriptTypography.applyFallbackToTheme(baseTheme);

      expect(enhancedTheme.bodyMedium?.fontFamilyFallback, equals(MultiScriptTypography.canonicalFontFallback));
      expect(enhancedTheme.titleLarge?.fontFamilyFallback, equals(MultiScriptTypography.canonicalFontFallback));
    });
  });
}
