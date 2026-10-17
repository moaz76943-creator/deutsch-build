import 'package:flutter/material.dart';

/// Comprehensive BiDi & Typography controller for all 100 polyglot languages
class LanguageBiDiHelper {
  static const Set<String> _rtlLanguagePrefixes = {
    'ar',
    'fa',
    'ur',
    'ps',
    'sd',
    'ku',
    'ug',
    'ckb',
    'he',
    'iw',
    'yi'
  };

  /// Resolves text direction from any BCP-47 locale code
  static TextDirection getDirection(String bcp47Code) {
    final prefix = bcp47Code.split('-').first.toLowerCase();
    if (_rtlLanguagePrefixes.contains(prefix)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  /// Security / Policy filter
  static bool isLanguageAllowed(String bcp47Code) {
    final prefix = bcp47Code.split('-').first.toLowerCase();
    if (prefix == 'he' || prefix == 'iw') {
      return false;
    }
    return true;
  }

  /// Dynamic line-height engine to prevent clipping of complex scripts and diacritics
  static double getLineHeight(String bcp47Code) {
    final prefix = bcp47Code.split('-').first.toLowerCase();
    // Arabic-script languages: extra vertical padding for tashkeel and descenders
    if (['ar', 'fa', 'ur', 'ps', 'sd', 'ku', 'ug', 'ckb'].contains(prefix)) {
      return 1.45;
    }
    // Complex Indic scripts and Thai/Lao: room for vertical tone/vowel stacking
    if (['hi', 'bn', 'ta', 'te', 'mr', 'gu', 'kn', 'ml', 'pa', 'th', 'lo', 'my']
        .contains(prefix)) {
      return 1.40;
    }
    // CJK Box glyph balance
    if (['zh', 'ja', 'ko'].contains(prefix)) {
      return 1.30;
    }
    // Standard Latin and Cyrillic
    return 1.20;
  }
}
