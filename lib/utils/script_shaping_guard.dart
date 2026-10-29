import 'package:flutter/painting.dart';

/// Unicode script hints and system-font fallbacks (including Android 8-10).
/// Does not replace characters or guarantee font coverage without font assets.
class ScriptShapingGuard {
  ScriptShapingGuard._();

  static const Map<String, String> _fonts = {
    'Devanagari': 'Noto Sans Devanagari',
    'Bengali': 'Noto Sans Bengali',
    'Gurmukhi': 'Noto Sans Gurmukhi',
    'Gujarati': 'Noto Sans Gujarati',
    'Oriya': 'Noto Sans Oriya',
    'Tamil': 'Noto Sans Tamil',
    'Telugu': 'Noto Sans Telugu',
    'Kannada': 'Noto Sans Kannada',
    'Malayalam': 'Noto Sans Malayalam',
    'Sinhala': 'Noto Sans Sinhala',
    'Thai': 'Noto Sans Thai',
    'Lao': 'Noto Sans Lao',
    'Khmer': 'Noto Sans Khmer',
    'Tibetan': 'Noto Sans Tibetan',
    'Georgian': 'Noto Sans Georgian',
    'Myanmar': 'Noto Sans Myanmar',
  };

  static String? scriptOf(int cp) {
    bool inside(int start, int end) => cp >= start && cp <= end;
    if (inside(0x0900, 0x097F) || inside(0xA8E0, 0xA8FF) ||
        inside(0x1CD0, 0x1CFF)) return 'Devanagari';
    if (inside(0x0980, 0x09FF)) return 'Bengali';
    if (inside(0x0A00, 0x0A7F)) return 'Gurmukhi';
    if (inside(0x0A80, 0x0AFF)) return 'Gujarati';
    if (inside(0x0B00, 0x0B7F)) return 'Oriya';
    if (inside(0x0B80, 0x0BFF)) return 'Tamil';
    if (inside(0x0C00, 0x0C7F)) return 'Telugu';
    if (inside(0x0C80, 0x0CFF)) return 'Kannada';
    if (inside(0x0D00, 0x0D7F)) return 'Malayalam';
    if (inside(0x0D80, 0x0DFF)) return 'Sinhala';
    if (inside(0x0E00, 0x0E7F)) return 'Thai';
    if (inside(0x0E80, 0x0EFF)) return 'Lao';
    if (inside(0x1780, 0x17FF) || inside(0x19E0, 0x19FF)) return 'Khmer';
    if (inside(0x0F00, 0x0FFF)) return 'Tibetan';
    if (inside(0x10A0, 0x10FF) || inside(0x1C90, 0x1CBF) ||
        inside(0x2D00, 0x2D2F)) return 'Georgian';
    if (inside(0x1000, 0x109F) || inside(0xAA60, 0xAA7F) ||
        inside(0xA9E0, 0xA9FF)) return 'Myanmar';
    return null;
  }

  static List<String> scriptsIn(String text) {
    final scripts = <String>{};
    for (final cp in text.runes) {
      final script = scriptOf(cp);
      if (script != null) scripts.add(script);
    }
    return List<String>.unmodifiable(scripts);
  }

  static List<String> fallbackFamiliesFor(String text, {
    List<String> existing = const [],
    int? androidSdkInt,
  }) {
    final scripts = scriptsIn(text);
    final fonts = <String>{...existing};
    for (final script in scripts) {
      final font = _fonts[script];
      if (font != null) fonts.add(font);
    }
    if (scripts.isNotEmpty) {
      if (androidSdkInt == null ||
          androidSdkInt < 26 || androidSdkInt > 29) {
        fonts.add('Noto Sans');
      }
      fonts.add('sans-serif');
    }
    return List<String>.unmodifiable(fonts);
  }

  static TextStyle styleFor(String text, {
    TextStyle base = const TextStyle(),
    int? androidSdkInt,
  }) {
    if (scriptsIn(text).isEmpty) return base;
    return base.copyWith(fontFamilyFallback: fallbackFamiliesFor(text,
      existing: base.fontFamilyFallback ?? const [],
      androidSdkInt: androidSdkInt));
  }

  /// True only for literal replacement U+FFFD, not for font-renderer tofu.
  static bool containsReplacementCharacter(String text) =>
      text.runes.contains(0xFFFD);
}
