import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/theme/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography.getStyleForScript', () {
    test('returns style with correct fallbacks for latin script', () {
      final style = MultiScriptTypography.getStyleForScript('latn');
      expect(
        style.fontFamilyFallback,
        ['Roboto', 'Noto Sans', 'Arial', 'Helvetica', 'sans-serif'],
      );
    });

    test('returns style with correct fallbacks for arabic script', () {
      final style = MultiScriptTypography.getStyleForScript('arab');
      expect(
        style.fontFamilyFallback,
        [
          'Noto Sans Arabic',
          'Noto Naskh Arabic',
          'Geeza Pro',
          'Arial',
          'sans-serif'
        ],
      );
    });

    test('returns style with correct fallbacks for CJK script', () {
      final style = MultiScriptTypography.getStyleForScript('hani');
      expect(
        style.fontFamilyFallback,
        [
          'Noto Sans CJK SC',
          'Noto Sans CJK TC',
          'Noto Sans CJK JP',
          'Noto Sans CJK KR',
          'Noto Sans SC',
          'Noto Sans TC',
          'Noto Sans JP',
          'Noto Sans KR',
          'PingFang SC',
          'Hiragino Sans',
          'Yu Gothic',
          'Malgun Gothic',
          'sans-serif'
        ],
      );
    });

    test('returns style with correct fallbacks for unmapped script', () {
      final style = MultiScriptTypography.getStyleForScript('unknown');
      expect(
        style.fontFamilyFallback,
        ['Roboto', 'Noto Sans', 'Arial', 'Helvetica', 'sans-serif'], // Defaults to latin
      );
    });

    test('merges existing fallbacks without duplicates', () {
      const baseStyle = TextStyle(fontFamilyFallback: ['MyCustomFont', 'Arial', 'Roboto']);
      final style = MultiScriptTypography.getStyleForScript('latn', baseStyle: baseStyle);

      expect(
        style.fontFamilyFallback,
        ['Roboto', 'Noto Sans', 'Arial', 'Helvetica', 'sans-serif', 'MyCustomFont'],
      );
    });

    test('returns style with existing properties preserved', () {
      const baseStyle = TextStyle(fontSize: 16.0, color: Colors.red);
      final style = MultiScriptTypography.getStyleForScript('latn', baseStyle: baseStyle);

      expect(style.fontSize, 16.0);
      expect(style.color, Colors.red);
      expect(
        style.fontFamilyFallback,
        ['Roboto', 'Noto Sans', 'Arial', 'Helvetica', 'sans-serif'],
      );
    });
  });

  group('MultiScriptTypography.detectScriptFamily', () {
    test('detects script from direct script tag', () {
      expect(
        MultiScriptTypography.detectScriptFamily('arab'),
        ScriptFamily.arabic,
      );
    });

    test('detects script from language tag', () {
      expect(
        MultiScriptTypography.detectScriptFamily('ar'),
        ScriptFamily.arabic,
      );

      expect(
        MultiScriptTypography.detectScriptFamily('zh'),
        ScriptFamily.cjk,
      );
    });

    test('detects script from BCP-47 explicit tag', () {
      expect(
        MultiScriptTypography.detectScriptFamily('sr-Latn'),
        ScriptFamily.latin,
      );

      expect(
        MultiScriptTypography.detectScriptFamily('az-Arab'),
        ScriptFamily.arabic,
      );
    });

    test('normalizes input appropriately', () {
      expect(
        MultiScriptTypography.detectScriptFamily(' SR_Latn '),
        ScriptFamily.latin,
      );
    });

    test('defaults to latin for empty string', () {
      expect(
        MultiScriptTypography.detectScriptFamily(''),
        ScriptFamily.latin,
      );
    });

    test('defaults to latin for unknown language', () {
      expect(
        MultiScriptTypography.detectScriptFamily('xx-YY'),
        ScriptFamily.latin,
      );
    });
  });
}
