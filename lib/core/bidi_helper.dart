import 'package:flutter/material.dart';

class BiDiHelper {
  static const String ltrMark = '‎';
  static const String rtlMark = '‏';

  static String wrapLtr(String text) {
    return '$ltrMark$text$ltrMark';
  }

  static String wrapRtl(String text) {
    return '$rtlMark$text$rtlMark';
  }

  /// Accurate TextDirection resolution for 100 languages.
  /// Skips leading neutrals/punctuations and inspects true script direction.
  static TextDirection getTextDirection(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return TextDirection.ltr;

    for (int i = 0; i < clean.length; i++) {
      final code = clean.codeUnitAt(i);
      // Skip neutral characters (whitespace, punctuation, brackets, symbols, digits)
      if (code <= 0x0040 || (code >= 0x005B && code <= 0x0060) || (code >= 0x007B && code <= 0x00BF)) {
        continue;
      }

      // Check RTL Unicode Blocks:
      // Hebrew (0x0590-0x05FF), Arabic & Arabic Supplement (0x0600-0x06FF, 0x0750-0x077F, 0x08A0-0x08FF)
      // Syriac (0x0700-0x074F), Thaana (0x0780-0x07BF), N'Ko (0x07C0-0x07FA)
      // Presentation forms (0xFB50-0xFDFF, 0xFE70-0xFEFF)
      if ((code >= 0x0590 && code <= 0x08FF) ||
          (code >= 0xFB1D && code <= 0xFDFF) ||
          (code >= 0xFE70 && code <= 0xFEFF)) {
        return TextDirection.rtl;
      }
      return TextDirection.ltr;
    }

    return TextDirection.ltr;
  }
}
