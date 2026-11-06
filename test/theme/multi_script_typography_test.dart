import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/theme/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography.getStyleForScript', () {
    test('returns style with correct script fallbacks when no baseStyle is provided', () {
      final style = MultiScriptTypography.getStyleForScript('arab');

      expect(style.fontFamilyFallback, isNotNull);
      expect(style.fontFamilyFallback, containsAll([
        'Noto Sans Arabic',
        'Noto Naskh Arabic',
        'Geeza Pro',
        'Arial',
        'sans-serif',
      ]));
    });

    test('appends existing baseStyle fallbacks to the new fallbacks without duplication', () {
      const baseStyle = TextStyle(
        fontFamilyFallback: ['MyCustomFont', 'Arial'],
      );

      final style = MultiScriptTypography.getStyleForScript('latn', baseStyle: baseStyle);

      expect(style.fontFamilyFallback, isNotNull);
      // 'Arial' is in both, should only appear once.
      // The order should be script fallbacks first, then existing fallbacks.
      final fallbacks = style.fontFamilyFallback!;
      expect(fallbacks, contains('MyCustomFont'));

      final expectedFallbacks = [
        'Roboto',
        'Noto Sans',
        'Arial',
        'Helvetica',
        'sans-serif',
        'MyCustomFont',
      ];
      expect(fallbacks, equals(expectedFallbacks));
    });

    test('falls back to latin script when scriptCode is unknown', () {
      final style = MultiScriptTypography.getStyleForScript('unknown_script_code');

      expect(style.fontFamilyFallback, isNotNull);
      expect(style.fontFamilyFallback, containsAll([
        'Roboto',
        'Noto Sans',
        'Arial',
        'Helvetica',
        'sans-serif',
      ]));
    });

    test('resolves language codes to correct scripts', () {
      final style = MultiScriptTypography.getStyleForScript('ja');

      expect(style.fontFamilyFallback, isNotNull);
      expect(style.fontFamilyFallback, contains('Noto Sans CJK JP'));
    });

    test('resolves composite language codes', () {
      final style = MultiScriptTypography.getStyleForScript('zh-Hant');

      expect(style.fontFamilyFallback, isNotNull);
      expect(style.fontFamilyFallback, contains('Noto Sans CJK TC'));
    });
  });
}
