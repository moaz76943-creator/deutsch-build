import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/design/bidi_text_isolator.dart';

void main() {
  group('BiDiTextIsolator Tests', () {
    test('Encloses German text in strict LRI boundaries', () {
      final isolated = BiDiTextIsolator.isolateGerman('das Haus');
      expect(isolated, '\u2066das Haus\u2069');
    });

    test('Encloses Arabic text in strict RLI boundaries', () {
      final isolated = BiDiTextIsolator.isolateArabic('البيت');
      expect(isolated, '\u2067البيت\u2069');
    });

    test('Formats bilingual pair without punctuation bleed', () {
      final pair = BiDiTextIsolator.formatBilingualPair('der Zug (m)', 'القطار (مذكر)');
      expect(pair, '\u2066der Zug (m)\u2069 — \u2067القطار (مذكر)\u2069');
    });
  });
}
