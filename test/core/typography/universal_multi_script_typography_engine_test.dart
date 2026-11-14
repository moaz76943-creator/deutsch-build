import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/typography/universal_script_shaper.dart';
import 'package:deutsch_build/src/core/typography/universal_multi_script_typography_engine.dart';

void main() {
  group('UniversalMultiScriptTypographyEngine Tests', () {
    const engine = UniversalMultiScriptTypographyEngine();

    test('Detects script families accurately from Unicode runes', () {
      expect(UniversalScriptShaper.detectScript('مرحبا بكم'), equals(ScriptType.arabicPersianUrdu));
      expect(UniversalScriptShaper.detectScript('Здравствуйте'), equals(ScriptType.cyrillic));
      expect(UniversalScriptShaper.detectScript('日本語のテスト'), equals(ScriptType.cjk));
      expect(UniversalScriptShaper.detectScript('한국어 테스트'), equals(ScriptType.cjk));
      expect(UniversalScriptShaper.detectScript('Guten Tag Deutschland'), equals(ScriptType.latin));
    });

    test('Isolates bidirectional tokens preventing punctuation clash', () {
      const arabicWord = 'كتاب';
      final isolatedAr = UniversalScriptShaper.isolateToken(arabicWord);
      expect(isolatedAr, startsWith(UniversalScriptShaper.rli));
      expect(isolatedAr, endsWith(UniversalScriptShaper.pdi));

      const germanWord = 'Kühlschrank';
      final isolatedDe = UniversalScriptShaper.isolateToken(germanWord);
      expect(isolatedDe, startsWith(UniversalScriptShaper.lri));
      expect(isolatedDe, endsWith(UniversalScriptShaper.pdi));
    });

    test('Resolves proper font fallback and normalized height metrics', () {
      final arStyle = engine.getAdaptiveStyle(text: 'سلام');
      expect(arStyle.fontFamily, equals('NotoSansArabic'));
      expect(arStyle.height, equals(1.45));

      final latinStyle = engine.getAdaptiveStyle(text: 'Hello');
      expect(latinStyle.fontFamily, equals('NotoSansLatin'));
      expect(latinStyle.height, equals(1.25));
    });
  });
}
