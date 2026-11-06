import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/theme/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography.getStyleForScript tests', () {
    test('returns style with default latin fallbacks when script code is empty', () {
      final style = MultiScriptTypography.getStyleForScript('');
      expect(style.fontFamilyFallback, isNotNull);
      expect(style.fontFamilyFallback, contains('Roboto'));
    });

    test('returns style with correct fallbacks for Arabic', () {
      final style = MultiScriptTypography.getStyleForScript('ar');
      expect(style.fontFamilyFallback, isNotNull);
      expect(style.fontFamilyFallback, contains('Noto Sans Arabic'));
      expect(style.fontFamilyFallback, contains('Geeza Pro'));
    });

    test('returns style with correct fallbacks for Devanagari', () {
      final style = MultiScriptTypography.getStyleForScript('hi');
      expect(style.fontFamilyFallback, isNotNull);
      expect(style.fontFamilyFallback, contains('Noto Sans Devanagari'));
    });

    test('preserves existing baseStyle fallbacks and deduplicates', () {
      const baseStyle = TextStyle(
        fontFamilyFallback: ['MyCustomFont', 'Roboto'],
      );
      final style = MultiScriptTypography.getStyleForScript('en', baseStyle: baseStyle);

      expect(style.fontFamilyFallback, isNotNull);
      // It should contain both default latin fallbacks and the custom one.
      expect(style.fontFamilyFallback, contains('MyCustomFont'));
      expect(style.fontFamilyFallback, contains('Roboto'));

      // Deduplication check: 'Roboto' should appear only once in the merged list.
      final robotoCount = style.fontFamilyFallback!.where((font) => font == 'Roboto').length;
      expect(robotoCount, equals(1));
    });

    test('returns style for unknown script defaulting to latin', () {
      final style = MultiScriptTypography.getStyleForScript('unknown-script');
      expect(style.fontFamilyFallback, isNotNull);
      expect(style.fontFamilyFallback, contains('Roboto'));
    });

    test('detects explicit script tags', () {
      final style = MultiScriptTypography.getStyleForScript('sr-Latn');
      // Latn gives latin fallback
      expect(style.fontFamilyFallback, contains('Roboto'));
    });
  });
}
