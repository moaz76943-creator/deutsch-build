import 'package:flutter/material.dart';
import 'font_fallback_engine.dart';

class AppTypography {
  static const String defaultFontFamily = 'Cairo';

  static const TextStyle label = TextStyle(
        fontFamily: defaultFontFamily,
        fontFamilyFallback: FontFallbackEngine.universalFallback,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  static const TextStyle display = TextStyle(
        fontFamily: defaultFontFamily,
        fontFamilyFallback: FontFallbackEngine.universalFallback,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static const TextStyle title = TextStyle(
        fontFamily: defaultFontFamily,
        fontFamilyFallback: FontFallbackEngine.universalFallback,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      );

  static const TextStyle h1 = TextStyle(
        fontFamily: defaultFontFamily,
        fontFamilyFallback: FontFallbackEngine.universalFallback,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

  static const TextStyle h2 = TextStyle(
        fontFamily: defaultFontFamily,
        fontFamilyFallback: FontFallbackEngine.universalFallback,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );

  static const TextStyle body = TextStyle(
        fontFamily: defaultFontFamily,
        fontFamilyFallback: FontFallbackEngine.universalFallback,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static const TextStyle caption = TextStyle(
        fontFamily: defaultFontFamily,
        fontFamilyFallback: FontFallbackEngine.universalFallback,
        fontSize: 12,
        fontWeight: FontWeight.w300,
      );
}
