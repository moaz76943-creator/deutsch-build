import 'package:flutter/material.dart';

class AppTypography {
  static const List<String> fallbackFontFamilies = [
    'Noto Sans Arabic',
    'Noto Sans Hebrew',
    'Noto Sans Devanagari',
    'Noto Sans Ethiopic',
    'Noto Sans SC',
    'Noto Sans Georgian',
    'Noto Sans Armenian',
  ];

  static const TextStyle label = TextStyle(
    fontFamily: 'Cairo',
    fontFamilyFallback: fallbackFontFamilies,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle display = TextStyle(
    fontFamily: 'Cairo',
    fontFamilyFallback: fallbackFontFamilies,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'Cairo',
    fontFamilyFallback: fallbackFontFamilies,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: 'Cairo',
    fontFamilyFallback: fallbackFontFamilies,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Cairo',
    fontFamilyFallback: fallbackFontFamilies,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Cairo',
    fontFamilyFallback: fallbackFontFamilies,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Cairo',
    fontFamilyFallback: fallbackFontFamilies,
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );
}
