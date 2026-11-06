import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/theme/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography.detectScriptFamily', () {
    test('Empty and whitespace strings default to latin', () {
      expect(MultiScriptTypography.detectScriptFamily(''), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily(' '), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('   '), equals(ScriptFamily.latin));
    });

    test('Direct script code lookups match correctly', () {
      expect(MultiScriptTypography.detectScriptFamily('latn'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('arab'), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('cyrl'), equals(ScriptFamily.cyrillic));
      expect(MultiScriptTypography.detectScriptFamily('hani'), equals(ScriptFamily.cjk));
      expect(MultiScriptTypography.detectScriptFamily('deva'), equals(ScriptFamily.devanagari));
      expect(MultiScriptTypography.detectScriptFamily('jpan'), equals(ScriptFamily.cjk));
    });

    test('BCP-47 fallback uses explicit script subtag over default language script', () {
      // Serbian defaults to Cyrillic, but sr-Latn uses Latin
      expect(MultiScriptTypography.detectScriptFamily('sr-Latn'), equals(ScriptFamily.latin));

      // Azerbaijani isn't in default list, but explicit subtag arab works
      expect(MultiScriptTypography.detectScriptFamily('az-Arab'), equals(ScriptFamily.arabic));

      // Traditional Chinese
      expect(MultiScriptTypography.detectScriptFamily('zh-Hant'), equals(ScriptFamily.cjk));

      // Explicit script in later parts
      expect(MultiScriptTypography.detectScriptFamily('en-US-Arab-123'), equals(ScriptFamily.arabic));
    });

    test('Default language resolution without explicit script subtag', () {
      expect(MultiScriptTypography.detectScriptFamily('ru'), equals(ScriptFamily.cyrillic));
      expect(MultiScriptTypography.detectScriptFamily('ar'), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('zh'), equals(ScriptFamily.cjk));
      expect(MultiScriptTypography.detectScriptFamily('hi'), equals(ScriptFamily.devanagari));

      // With region but no script, uses language default
      expect(MultiScriptTypography.detectScriptFamily('zh-CN'), equals(ScriptFamily.cjk));
      expect(MultiScriptTypography.detectScriptFamily('ru-RU'), equals(ScriptFamily.cyrillic));
    });

    test('Handles underscores instead of hyphens', () {
      expect(MultiScriptTypography.detectScriptFamily('zh_Hans_CN'), equals(ScriptFamily.cjk));
      expect(MultiScriptTypography.detectScriptFamily('sr_Latn'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('ru_RU'), equals(ScriptFamily.cyrillic));
    });

    test('Unknown languages or script tags default to latin', () {
      expect(MultiScriptTypography.detectScriptFamily('unknown'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('xx-yyy'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('en'), equals(ScriptFamily.latin)); // 'en' is not in _languageScripts
      expect(MultiScriptTypography.detectScriptFamily('fr-FR'), equals(ScriptFamily.latin)); // 'fr' is not in _languageScripts
    });

    test('Case insensitivity is handled correctly', () {
      expect(MultiScriptTypography.detectScriptFamily('LATN'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('Cyrl'), equals(ScriptFamily.cyrillic));
      expect(MultiScriptTypography.detectScriptFamily('ZH-hans-cn'), equals(ScriptFamily.cjk));
    });
  });
}
