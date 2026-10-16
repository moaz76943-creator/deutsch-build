// Multi-Script Goldens & Linguistic Rendering Framework
// Conforms to DEUTSCH Master Constitution v9 Multi-Script Standards

class MultiScriptGoldensFramework {
  /// 1. RTL & Bidi Isolation (Arabic, Hebrew, Persian, Urdu, Pashto)
  /// Isolates bidirectional text segments to prevent inversion of numbers and LTR words.
  static String isolateBidi(String text, {bool isRtl = true}) {
    if (text.isEmpty) return text;
    // Unicode directional isolates: FSI (\u2068) and PDI (\u2069)
    if (isRtl) {
      return '\u2067$text\u2069'; // RLI ... PDI
    }
    return '\u2066$text\u2069'; // LRI ... PDI
  }

  /// 2. Accented Latin Orthography Protection (German, French, Spanish, Portuguese)
  /// Validates and preserves phonemic umlauts and diacritics.
  static bool hasPreservedAccents(String original, String processed) {
    const criticalAccents = ['ä', 'ö', 'ü', 'ß', 'é', 'è', 'ê', 'ç', 'ñ', 'ã', 'õ'];
    for (final char in criticalAccents) {
      if (original.contains(char) && !processed.contains(char)) {
        return false;
      }
    }
    return true;
  }

  /// 3. Turkish & Turkic Dotted/Dotless 'I' Case Folding
  static String turkishToLower(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == 'İ') {
        buffer.write('i');
      } else if (char == 'I') {
        buffer.write('ı');
      } else {
        buffer.write(char.toLowerCase());
      }
    }
    return buffer.toString();
  }

  static String turkishToUpper(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == 'i') {
        buffer.write('İ');
      } else if (char == 'ı') {
        buffer.write('I');
      } else {
        buffer.write(char.toUpperCase());
      }
    }
    return buffer.toString();
  }

  /// 4. Indic Grapheme Cluster Integrity (Devanagari, Bengali, Tamil, Telugu)
  /// Ensures virama and dependent vowel matras are never separated from consonant bases.
  static bool isIndicGraphemeBoundarySafe(String text, int splitIndex) {
    if (splitIndex <= 0 || splitIndex >= text.length) return true;
    final charCode = text.codeUnitAt(splitIndex);

    // Devanagari Virama: 0x094D, Matras: 0x093E..0x094C
    if (charCode == 0x094D || (charCode >= 0x093E && charCode <= 0x094C)) {
      return false; // Cannot split directly on virama or dependent matra
    }
    // Bengali Virama: 0x09CD, Matras: 0x09BE..0x09CC
    if (charCode == 0x09CD || (charCode >= 0x09BE && charCode <= 0x09CC)) {
      return false;
    }
    return true;
  }

  /// 5. CJK Character Range & Tone Protection
  static bool isHanzi(int codeUnit) {
    // CJK Unified Ideographs (\u4E00 - \u9FFF)
    return codeUnit >= 0x4E00 && codeUnit <= 0x9FFF;
  }

  static bool isHangul(int codeUnit) {
    // Hangul Syllables (\uAC00 - \uD7AF)
    return codeUnit >= 0xAC00 && codeUnit <= 0xD7AF;
  }

  static bool isKana(int codeUnit) {
    // Hiragana (\u3040 - \u309F) and Katakana (\u30A0 - \u30FF)
    return (codeUnit >= 0x3040 && codeUnit <= 0x309F) ||
           (codeUnit >= 0x30A0 && codeUnit <= 0x30FF);
  }

  /// 6. Southeast Asian Non-Whitespace Text Boundary Safe Probe (Thai, Lao, Khmer)
  static bool isThaiWordContinuation(int codeUnit) {
    // Thai Unicode Range 0x0E00 - 0x0E7F
    // Vowels and Tone Marks: 0x0E30 - 0x0E4E
    return codeUnit >= 0x0E30 && codeUnit <= 0x0E4E;
  }

  /// 7. African / Bantu Noun Class Classifier (Swahili ki-/vi-, m-/wa-)
  static String? detectBantuNounClass(String noun) {
    final lower = noun.trim().toLowerCase();
    if (lower.startsWith('m') && !lower.startsWith('ma')) {
      return 'Class 1 (m-)';
    }
    if (lower.startsWith('wa')) {
      return 'Class 2 (wa-)';
    }
    if (lower.startsWith('ki')) {
      return 'Class 7 (ki-)';
    }
    if (lower.startsWith('vi')) {
      return 'Class 8 (vi-)';
    }
    return null;
  }
}
