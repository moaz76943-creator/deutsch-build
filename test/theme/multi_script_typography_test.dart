import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/theme/multi_script_typography.dart';

void main() {
  group('MultiScriptTypography.detectScriptFamily', () {
    test('returns latin for empty or whitespace strings', () {
      expect(MultiScriptTypography.detectScriptFamily(''), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('   '), equals(ScriptFamily.latin));
    });

    test('resolves direct script tags (e.g. latn, arab)', () {
      expect(MultiScriptTypography.detectScriptFamily('arab'), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('cyrl'), equals(ScriptFamily.cyrillic));
      expect(MultiScriptTypography.detectScriptFamily('grek'), equals(ScriptFamily.greek));
    });

    test('resolves explicit script subtags in BCP-47 codes taking precedence over language defaults', () {
      // az-Arab -> Arabic, sr-Latn -> Latin, sr-Cyrl -> Cyrillic
      expect(MultiScriptTypography.detectScriptFamily('az-Arab'), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('sr-Latn'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('sr-Cyrl'), equals(ScriptFamily.cyrillic));
      // With underscores instead of dashes
      expect(MultiScriptTypography.detectScriptFamily('zh_Hant'), equals(ScriptFamily.cjk));
    });

    test('resolves by language code when no script subtag is present', () {
      expect(MultiScriptTypography.detectScriptFamily('ar'), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('ar-SA'), equals(ScriptFamily.arabic));
      expect(MultiScriptTypography.detectScriptFamily('ru'), equals(ScriptFamily.cyrillic));
      expect(MultiScriptTypography.detectScriptFamily('hi'), equals(ScriptFamily.devanagari));
      expect(MultiScriptTypography.detectScriptFamily('zh-CN'), equals(ScriptFamily.cjk));
    });

    test('defaults to latin for unknown language codes', () {
      expect(MultiScriptTypography.detectScriptFamily('xx'), equals(ScriptFamily.latin));
      expect(MultiScriptTypography.detectScriptFamily('xx-YY'), equals(ScriptFamily.latin));
    });
  });
}
