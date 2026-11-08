import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/theme/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography.getStyleForScript', () {
    test('applies latin fallbacks for unknown or empty script code', () {
      final styleEmpty = MultiScriptTypography.getStyleForScript('');
      expect(styleEmpty.fontFamilyFallback, isNotNull);
      expect(styleEmpty.fontFamilyFallback!.first, 'Roboto');
      expect(styleEmpty.fontFamilyFallback!.contains('sans-serif'), isTrue);

      final styleUnknown = MultiScriptTypography.getStyleForScript('unknown_code');
      expect(styleUnknown.fontFamilyFallback, isNotNull);
      expect(styleUnknown.fontFamilyFallback!.first, 'Roboto');
    });

    test('applies exact mapping fallbacks for known script codes', () {
      // Cyrillic script
      final cyrillicStyle = MultiScriptTypography.getStyleForScript('cyrl');
      expect(cyrillicStyle.fontFamilyFallback, isNotNull);
      expect(cyrillicStyle.fontFamilyFallback!.first, 'Roboto');

      // Arabic script
      final arabicStyle = MultiScriptTypography.getStyleForScript('arab');
      expect(arabicStyle.fontFamilyFallback, isNotNull);
      expect(arabicStyle.fontFamilyFallback!.first, 'Noto Sans Arabic');

      // CJK script
      final cjkStyle = MultiScriptTypography.getStyleForScript('hani');
      expect(cjkStyle.fontFamilyFallback, isNotNull);
      expect(cjkStyle.fontFamilyFallback!.first, 'Noto Sans CJK SC');
      expect(cjkStyle.fontFamilyFallback!.contains('Hiragino Sans'), isTrue);
    });

    test('resolves fallbacks correctly from language code', () {
      // Thai language
      final thaiStyle = MultiScriptTypography.getStyleForScript('th');
      expect(thaiStyle.fontFamilyFallback, isNotNull);
      expect(thaiStyle.fontFamilyFallback!.first, 'Noto Sans Thai');

      // BCP-47 style with explicit script
      final azerbaijaniArabicStyle = MultiScriptTypography.getStyleForScript('az-Arab');
      expect(azerbaijaniArabicStyle.fontFamilyFallback, isNotNull);
      expect(azerbaijaniArabicStyle.fontFamilyFallback!.first, 'Noto Sans Arabic');
    });

    test('merges existing fallbacks from baseStyle without duplicates', () {
      const baseStyle = TextStyle(
        fontFamilyFallback: ['CustomFont', 'sans-serif'],
      );

      final mergedStyle = MultiScriptTypography.getStyleForScript('arab', baseStyle: baseStyle);

      expect(mergedStyle.fontFamilyFallback, isNotNull);
      expect(mergedStyle.fontFamilyFallback!.first, 'Noto Sans Arabic');

      // Should contain the original existing fallbacks
      expect(mergedStyle.fontFamilyFallback!.contains('CustomFont'), isTrue);

      // Should not contain duplicate 'sans-serif' which is present in both Arabic fallbacks and baseStyle
      final sansSerifCount = mergedStyle.fontFamilyFallback!.where((font) => font == 'sans-serif').length;
      expect(sansSerifCount, 1);
    });

    test('retains original text style properties', () {
      const baseStyle = TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Colors.red,
      );

      final resultStyle = MultiScriptTypography.getStyleForScript('latn', baseStyle: baseStyle);

      expect(resultStyle.fontSize, 18.0);
      expect(resultStyle.fontWeight, FontWeight.w600);
      expect(resultStyle.color, Colors.red);
      expect(resultStyle.fontFamilyFallback, isNotEmpty);
    });
  });
}
