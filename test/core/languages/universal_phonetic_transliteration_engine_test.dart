import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/universal_phonetic_transliteration_engine.dart';

void main() {
  group('UniversalPhoneticTransliterationEngine Tests', () {
    const engine = UniversalPhoneticTransliterationEngine();

    test('Transliterates Russian Cyrillic accurately', () {
      expect(engine.transliterateToLatin('Москва'), equals('Moskva'));
      expect(engine.transliterateToLatin('спасибо'), equals('spasibo'));
    });

    test('Transliterates Greek script accurately', () {
      expect(engine.transliterateToLatin('Ελλάδα'), equals('Ellada'));
    });

    test('Transliterates Devanagari script accurately', () {
      expect(engine.transliterateToLatin('नमस्ते'), contains('n'));
    });
  });
}
