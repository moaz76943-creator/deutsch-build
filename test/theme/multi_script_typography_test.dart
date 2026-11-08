import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/theme/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography.detectScriptFamily', () {
    test('returns latin for empty or whitespace strings', () {
      expect(MultiScriptTypography.detectScriptFamily(''), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('   '), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('\n\t'), equals(ScriptFamily.latin));
    });

    test('returns correct script for explicit BCP-47 script tags (direct match)', () {
      expect(MultiScriptTypography.detectScriptFamily('latn'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('cyrl'), equals(ScriptFamily.cyrillic));
      expect(MultiScriptTypography.detectScriptFamily('arab'), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('hani'), equals(ScriptFamily.cjk));
      expect(MultiScriptTypography.detectScriptFamily('jpan'), equals(ScriptFamily.cjk));
    });

    test('returns correct script for language tags with script subtags', () {
      expect(MultiScriptTypography.detectScriptFamily('sr-Latn'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('az-Arab'), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('zh-Hant'), equals(ScriptFamily.cjk));
      expect(MultiScriptTypography.detectScriptFamily('zh-Hans-CN'), equals(ScriptFamily.cjk));
      // Should find the script even if there are regions before it (though invalid BCP-47, tests iteration)
      expect(MultiScriptTypography.detectScriptFamily('en-US-Arab'), equals(ScriptFamily.arabic));
    });

    test('returns correct script based on language defaults', () {
      expect(MultiScriptTypography.detectScriptFamily('ru'), equals(ScriptFamily.cyrillic));
      expect(MultiScriptTypography.detectScriptFamily('ar'), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('fa'), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('hi'), equals(ScriptFamily.devanagari));
      expect(MultiScriptTypography.detectScriptFamily('zh'), equals(ScriptFamily.cjk));
      expect(MultiScriptTypography.detectScriptFamily('ja'), equals(ScriptFamily.cjk));
      expect(MultiScriptTypography.detectScriptFamily('ko'), equals(ScriptFamily.cjk));
      expect(MultiScriptTypography.detectScriptFamily('th'), equals(ScriptFamily.thai));
      expect(MultiScriptTypography.detectScriptFamily('el'), equals(ScriptFamily.greek));
    });

    test('handles variations in casing and separators', () {
      expect(MultiScriptTypography.detectScriptFamily('SR_LATN'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('  az_arab  '), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('ZH_hant'), equals(ScriptFamily.cjk));
      expect(MultiScriptTypography.detectScriptFamily('RU-ru'), equals(ScriptFamily.cyrillic));
    });

    test('returns latin as fallback for unknown languages', () {
      expect(MultiScriptTypography.detectScriptFamily('en'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('fr'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('de'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('es'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('unknown'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('foo-bar'), equals(ScriptFamily.latin));
    });
  });
}
