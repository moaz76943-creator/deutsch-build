import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/theme/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography.detectScriptFamily', () {
    test('returns latin for empty or whitespace strings', () {
      expect(MultiScriptTypography.detectScriptFamily(''), ScriptFamily.latin);
      expect(MultiScriptTypography.detectScriptFamily('   '), ScriptFamily.latin);
    });

    test('resolves direct script tags', () {
      expect(MultiScriptTypography.detectScriptFamily('arab'), ScriptFamily.arabic);
      expect(MultiScriptTypography.detectScriptFamily('Cyrl'), ScriptFamily.cyrillic);
      expect(MultiScriptTypography.detectScriptFamily('Hant'), ScriptFamily.cjk);
    });

    test('resolves simple language codes based on default mapping', () {
      expect(MultiScriptTypography.detectScriptFamily('ru'), ScriptFamily.cyrillic);
      expect(MultiScriptTypography.detectScriptFamily('ar'), ScriptFamily.arabic);
      expect(MultiScriptTypography.detectScriptFamily('zh'), ScriptFamily.cjk);
      expect(MultiScriptTypography.detectScriptFamily('th'), ScriptFamily.thai);
      expect(MultiScriptTypography.detectScriptFamily('hi'), ScriptFamily.devanagari);
    });

    test('resolves explicit BCP-47 script subtags with precedence', () {
      expect(MultiScriptTypography.detectScriptFamily('sr-Latn'), ScriptFamily.latin);
      expect(MultiScriptTypography.detectScriptFamily('sr-Cyrl'), ScriptFamily.cyrillic);
      expect(MultiScriptTypography.detectScriptFamily('zh-Hant'), ScriptFamily.cjk);
      expect(MultiScriptTypography.detectScriptFamily('zh-Hans'), ScriptFamily.cjk);
      expect(MultiScriptTypography.detectScriptFamily('az-Arab'), ScriptFamily.arabic);
    });

    test('handles underscore separators interchangeably with hyphens', () {
      expect(MultiScriptTypography.detectScriptFamily('sr_Latn'), ScriptFamily.latin);
      expect(MultiScriptTypography.detectScriptFamily('zh_Hant_TW'), ScriptFamily.cjk);
    });

    test('returns latin for unknown language codes', () {
      expect(MultiScriptTypography.detectScriptFamily('unknown'), ScriptFamily.latin);
      expect(MultiScriptTypography.detectScriptFamily('xx-YY'), ScriptFamily.latin);
    });
  });
}
