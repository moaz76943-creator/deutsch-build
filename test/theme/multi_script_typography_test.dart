import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/theme/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography.detectScriptFamily', () {
    test('returns latin for empty or whitespace input', () {
      expect(MultiScriptTypography.detectScriptFamily(''), ScriptFamily.latin);
      expect(MultiScriptTypography.detectScriptFamily('   '), ScriptFamily.latin);
    });

    test('returns latin for unknown language code', () {
      expect(MultiScriptTypography.detectScriptFamily('en'), ScriptFamily.latin);
      expect(MultiScriptTypography.detectScriptFamily('fr'), ScriptFamily.latin);
      expect(MultiScriptTypography.detectScriptFamily('unknown'), ScriptFamily.latin);
    });

    group('direct script matches', () {
      test('resolves from script tags directly', () {
        expect(MultiScriptTypography.detectScriptFamily('latn'), ScriptFamily.latin);
        expect(MultiScriptTypography.detectScriptFamily('arab'), ScriptFamily.arabic);
        expect(MultiScriptTypography.detectScriptFamily('cyrl'), ScriptFamily.cyrillic);
        expect(MultiScriptTypography.detectScriptFamily('hans'), ScriptFamily.cjk);
        expect(MultiScriptTypography.detectScriptFamily('hant'), ScriptFamily.cjk);
      });

      test('is case insensitive', () {
        expect(MultiScriptTypography.detectScriptFamily('Latn'), ScriptFamily.latin);
        expect(MultiScriptTypography.detectScriptFamily('ARAB'), ScriptFamily.arabic);
        expect(MultiScriptTypography.detectScriptFamily('Cyrl'), ScriptFamily.cyrillic);
        expect(MultiScriptTypography.detectScriptFamily('Hans'), ScriptFamily.cjk);
      });
    });

    group('explicit subtag matches', () {
      test('prioritizes explicit BCP-47 script subtags', () {
        expect(MultiScriptTypography.detectScriptFamily('sr-Latn'), ScriptFamily.latin);
        expect(MultiScriptTypography.detectScriptFamily('az-Arab'), ScriptFamily.arabic);
        expect(MultiScriptTypography.detectScriptFamily('zh-Hant'), ScriptFamily.cjk);
        expect(MultiScriptTypography.detectScriptFamily('uz-Cyrl'), ScriptFamily.cyrillic);
      });

      test('handles underscores instead of hyphens', () {
        expect(MultiScriptTypography.detectScriptFamily('sr_Latn'), ScriptFamily.latin);
        expect(MultiScriptTypography.detectScriptFamily('az_Arab'), ScriptFamily.arabic);
        expect(MultiScriptTypography.detectScriptFamily('zh_Hant'), ScriptFamily.cjk);
        expect(MultiScriptTypography.detectScriptFamily('uz_Cyrl'), ScriptFamily.cyrillic);
      });

      test('is case insensitive for subtags', () {
        expect(MultiScriptTypography.detectScriptFamily('SR-LATN'), ScriptFamily.latin);
        expect(MultiScriptTypography.detectScriptFamily('az_arab'), ScriptFamily.arabic);
      });
    });

    group('language defaults', () {
      test('resolves based on language default when no script tag is present', () {
        expect(MultiScriptTypography.detectScriptFamily('ru'), ScriptFamily.cyrillic);
        expect(MultiScriptTypography.detectScriptFamily('ar'), ScriptFamily.arabic);
        expect(MultiScriptTypography.detectScriptFamily('zh'), ScriptFamily.cjk);
        expect(MultiScriptTypography.detectScriptFamily('hi'), ScriptFamily.devanagari);
        expect(MultiScriptTypography.detectScriptFamily('ja'), ScriptFamily.cjk);
        expect(MultiScriptTypography.detectScriptFamily('ko'), ScriptFamily.cjk);
      });

      test('resolves based on language default with regions (no explicit script)', () {
        expect(MultiScriptTypography.detectScriptFamily('ru-RU'), ScriptFamily.cyrillic);
        expect(MultiScriptTypography.detectScriptFamily('ar-SA'), ScriptFamily.arabic);
        expect(MultiScriptTypography.detectScriptFamily('zh-CN'), ScriptFamily.cjk);
      });
    });
  });
}
