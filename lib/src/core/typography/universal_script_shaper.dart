import 'package:flutter/material.dart';

/// Unicode Script classification detected for text segments.
enum ScriptType {
  latin,
  arabicPersianUrdu,
  cyrillic,
  cjk, // Chinese, Japanese, Korean
  unknown,
}

/// Helper for isolating and shaping multi-script bidirectional tokens.
class UniversalScriptShaper {
  // Unicode Directional Isolator Marks
  static const String lri = '\u2066'; // Left-to-Right Isolate
  static const String rli = '\u2067'; // Right-to-Left Isolate
  static const String pdi = '\u2069'; // Pop Directional Isolate

  /// Detects the dominant script family of a string based on Unicode ranges.
  static ScriptType detectScript(String text) {
    for (final rune in text.runes) {
      if ((rune >= 0x0600 && rune <= 0x06FF) || // Arabic
          (rune >= 0x0750 && rune <= 0x077F) || // Arabic Supplement
          (rune >= 0xFB50 && rune <= 0xFDFF) || // Arabic Pres-A
          (rune >= 0xFE70 && rune <= 0xFEFF)) { // Arabic Pres-B
        return ScriptType.arabicPersianUrdu;
      } else if (rune >= 0x0400 && rune <= 0x04FF) { // Cyrillic
        return ScriptType.cyrillic;
      } else if ((rune >= 0x4E00 && rune <= 0x9FFF) || // CJK Unified Ideographs
                 (rune >= 0x3040 && rune <= 0x309F) || // Hiragana
                 (rune >= 0x30A0 && rune <= 0x30FF) || // Katakana
                 (rune >= 0xAC00 && rune <= 0xD7AF)) { // Hangul Syllables
        return ScriptType.cjk;
      } else if ((rune >= 0x0041 && rune <= 0x005A) || // Latin A-Z
                 (rune >= 0x0061 && rune <= 0x007A) || // Latin a-z
                 (rune >= 0x00C0 && rune <= 0x024F)) { // Latin Extended
        return ScriptType.latin;
      }
    }
    return ScriptType.latin;
  }

  /// Determines whether text snippet requires Right-to-Left base direction.
  static bool isRtlText(String text) {
    return detectScript(text) == ScriptType.arabicPersianUrdu;
  }

  /// Wraps token with strict Unicode isolator to prevent punctuation mirroring.
  static String isolateToken(String text) {
    if (isRtlText(text)) {
      return '$rli$text$pdi';
    } else {
      return '$lri$text$pdi';
    }
  }
}
