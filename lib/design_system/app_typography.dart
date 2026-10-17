import 'package:flutter/material.dart';

class AppTypography {
  static const List<String> _fallbackFonts = [
    'NotoSansHebrew',
    'NotoSansDevanagari',
    'NotoSansEthiopic',
    'NotoSansGeorgian',
    'NotoSansArmenian',
    'NotoSansCJK',
  ];

  static const String fontFamily = 'Cairo';

  static const TextStyle label = TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fallbackFonts,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  static const TextStyle display = TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fallbackFonts,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static const TextStyle title = TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fallbackFonts,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      );

  static const TextStyle h1 = TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fallbackFonts,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

  static const TextStyle h2 = TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fallbackFonts,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );

  static const TextStyle body = TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fallbackFonts,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static const TextStyle caption = TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fallbackFonts,
        fontSize: 12,
        fontWeight: FontWeight.w300,
      );
}
