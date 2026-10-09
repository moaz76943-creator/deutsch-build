import 'package:flutter/material.dart';

class BiDiHelper {
  static const String ltrMark = '\u200E';
  static const String rtlMark = '\u200F';

  static String wrapLtr(String text) => '$ltrMark$text$ltrMark';
  static String wrapRtl(String text) => '$rtlMark$text$rtlMark';

  static TextDirection getTextDirection(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return TextDirection.ltr;
    final firstChar = clean.codeUnitAt(0);
    if (firstChar >= 0x0600 && firstChar <= 0x06FF) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }
}
