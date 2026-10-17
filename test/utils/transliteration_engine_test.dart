import 'package:deutsch_bilarabi/utils/transliteration_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransliterationEngine interface', () {
    test('returns null for an unsupported script and handles empty input', () {
      expect(TransliterationEngine.transliterateToLatin('東京', 'han'), isNull);
      expect(TransliterationEngine.transliterateToLatin('', 'japanese'), '');
      expect(TransliterationEngine.transliterateToLatin('  ', 'greek'), '  ');
      expect(TransliterationEngine.transliterateToLatin('Hello!', 'russian'),
          'Hello!');
    });

    test('uses case-insensitive script identifiers and common aliases', () {
      expect(TransliterationEngine.transliterateToLatin('Привет', ' Cyrillic '),
          'Privet');
      expect(TransliterationEngine.transliterateToLatin('Καλημέρα', 'EL'),
          'Kalimera');
      expect(TransliterationEngine.transliterateToLatin('きょう', 'ja'), 'kyō');
      expect(TransliterationEngine.transliterateToLatin('नमस्ते', 'HI'),
          'namaste');
    });
  });

  group('Cyrillic', () {
    test('romanizes Russian consonants and soft/hard signs', () {
      expect(TransliterationEngine.transliterateToLatin('Привет, мир!', 'ru'),
          'Privet, mir!');
      expect(TransliterationEngine.transliterateToLatin('Щука и подъезд', 'ru'),
          'Shchuka i podezd');
      expect(TransliterationEngine.transliterateToLatin('ЖУК', 'russian'),
          'ZHUK');
    });

    test('uses language-specific Ukrainian and Bulgarian rules', () {
      expect(TransliterationEngine.transliterateToLatin('Київ', 'uk'),
          'Kyiv');
      expect(TransliterationEngine.transliterateToLatin('Гора', 'uk'),
          'Hora');
      expect(TransliterationEngine.transliterateToLatin('България', 'bg'),
          'Balgariya');
    });
  });

  group('Greek', () {
    test('romanizes accented words, final sigma and capitalization', () {
      expect(TransliterationEngine.transliterateToLatin(
          'Καλημέρα κόσμε!', 'greek'), 'Kalimera kosme!');
      expect(TransliterationEngine.transliterateToLatin('Θεσσαλονίκη', 'el'),
          'Thessaloniki');
      expect(TransliterationEngine.transliterateToLatin('ΟΥΡΑΝΟΣ', 'el'),
          'OURANOS');
    });
  });

  group('Japanese Hepburn Kana', () {
    test('supports hiragana, katakana and voiced rows', () {
      expect(TransliterationEngine.transliterateToLatin('さくら', 'kana'),
          'sakura');
      expect(TransliterationEngine.transliterateToLatin('テレビ', 'ja'),
          'terebi');
      expect(TransliterationEngine.transliterateToLatin('こんにちは', 'ja'),
          'konnichiha'); // Literal kana; does not guess the は particle.
    });

    test('combines yoon digraphs, sokuon and nasal boundaries', () {
      expect(TransliterationEngine.transliterateToLatin('きょう', 'ja'),
          'kyō');
      expect(TransliterationEngine.transliterateToLatin('まっちゃ', 'ja'),
          'matcha');
      expect(TransliterationEngine.transliterateToLatin('がっこう', 'ja'),
          'gakkō');
      expect(TransliterationEngine.transliterateToLatin('しんよう', 'ja'),
          "shin'yō");
    });

    test('uses macrons for katakana long-vowel mark', () {
      expect(TransliterationEngine.transliterateToLatin('スーパー', 'katakana'),
          'sūpā');
      expect(TransliterationEngine.transliterateToLatin('コーヒー', 'ja'),
          'kōhī');
    });

    test('preserves unsupported kanji and punctuation', () {
      expect(TransliterationEngine.transliterateToLatin('東京・カフェ', 'ja'),
          '東京・kafe');
    });
  });

  group('Devanagari', () {
    test('handles inherent a, dependent vowel signs and halant', () {
      expect(TransliterationEngine.transliterateToLatin('नमस्ते', 'hi'),
          'namaste');
      expect(TransliterationEngine.transliterateToLatin('हिन्दी', 'devanagari'),
          'hindii');
      expect(TransliterationEngine.transliterateToLatin('भारत', 'hi'),
          'bhaarata');
    });
  });

  group('Arabic simplified Buckwalter', () {
    test('handles Arabic consonants, alef variants and short vowels', () {
      expect(TransliterationEngine.transliterateToLatin('سلام', 'ar'),
          'slAm');
      expect(TransliterationEngine.transliterateToLatin('كَتَبَ', 'arabic'),
          'kataba');
      expect(TransliterationEngine.transliterateToLatin('أحمد', 'ar'),
          '>Hmd');
    });
  });
}
