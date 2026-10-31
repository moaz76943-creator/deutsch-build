import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/linguistics/multi_script_goldens_framework.dart';

void main() {
  group('MultiScriptGoldensFramework - Multi-Script Linguistic Goldens (TASKS 061-070)', () {
    test('TASK-061: RTL and Bidi Isolation wraps bidirectional phrases safely', () {
      const phrase = 'تعلم اللغة الألمانية Deutsch 100%';
      final isolated = MultiScriptGoldensFramework.isolateBidi(phrase, isRtl: true);
      expect(isolated.startsWith('\u2067'), isTrue);
      expect(isolated.endsWith('\u2069'), isTrue);
      expect(isolated.contains(phrase), isTrue);
    });

    test('TASK-062: Accented Latin preserves critical umlauts and accents', () {
      const originalDe = 'Groß, schön, über, Mädchen';
      expect(MultiScriptGoldensFramework.hasPreservedAccents(originalDe, originalDe), isTrue);

      const strippedDe = 'Gross, schon, uber, Madchen';
      expect(MultiScriptGoldensFramework.hasPreservedAccents(originalDe, strippedDe), isFalse);

      const originalEs = 'Español, canción';
      expect(MultiScriptGoldensFramework.hasPreservedAccents(originalEs, originalEs), isTrue);
    });

    test('TASK-063: Turkish Dotted and Dotless I Case Folding is strictly distinct', () {
      expect(MultiScriptGoldensFramework.turkishToLower('İSTANBUL'), equals('istanbul'));
      expect(MultiScriptGoldensFramework.turkishToLower('IŞIK'), equals('ışık'));
      expect(MultiScriptGoldensFramework.turkishToUpper('istanbul'), equals('İSTANBUL'));
      expect(MultiScriptGoldensFramework.turkishToUpper('ışık'), equals('IŞIK'));
    });

    test('TASK-065: Indic Grapheme Cluster Integrity forbids splitting on virama or matra', () {
      // Devanagari 'कि' = क (0x0915) + ि (0x093F)
      const devanagariWord = 'किताब';
      expect(MultiScriptGoldensFramework.isIndicGraphemeBoundarySafe(devanagariWord, 1), isFalse);
      expect(MultiScriptGoldensFramework.isIndicGraphemeBoundarySafe(devanagariWord, 2), isTrue);

      // Devanagari 'क्' = क (0x0915) + ् (0x094D virama)
      const devanagariConjunct = 'क्या';
      expect(MultiScriptGoldensFramework.isIndicGraphemeBoundarySafe(devanagariConjunct, 1), isFalse);
    });

    test('TASK-066 & 067: CJK, Hangul, and Kana character identification', () {
      // Hanzi
      expect(MultiScriptGoldensFramework.isHanzi('学'.codeUnitAt(0)), isTrue);
      expect(MultiScriptGoldensFramework.isHanzi('A'.codeUnitAt(0)), isFalse);

      // Hangul
      expect(MultiScriptGoldensFramework.isHangul('한'.codeUnitAt(0)), isTrue);
      expect(MultiScriptGoldensFramework.isHangul('B'.codeUnitAt(0)), isFalse);

      // Kana
      expect(MultiScriptGoldensFramework.isKana('あ'.codeUnitAt(0)), isTrue);
      expect(MultiScriptGoldensFramework.isKana('ア'.codeUnitAt(0)), isTrue);
      expect(MultiScriptGoldensFramework.isKana('C'.codeUnitAt(0)), isFalse);
    });

    test('TASK-068: Southeast Asian non-space boundary detection', () {
      // Thai vowel sign ิ (0x0E34)
      const thaiWord = 'กิน';
      expect(MultiScriptGoldensFramework.isThaiWordContinuation(thaiWord.codeUnitAt(1)), isTrue);
    });

    test('TASK-069: Bantu Noun Class Classifier correctly groups Swahili nouns', () {
      expect(MultiScriptGoldensFramework.detectBantuNounClass('mtu'), equals('Class 1 (m-)'));
      expect(MultiScriptGoldensFramework.detectBantuNounClass('watu'), equals('Class 2 (wa-)'));
      expect(MultiScriptGoldensFramework.detectBantuNounClass('kitabu'), equals('Class 7 (ki-)'));
      expect(MultiScriptGoldensFramework.detectBantuNounClass('vitabu'), equals('Class 8 (vi-)'));
    });
  });
}
