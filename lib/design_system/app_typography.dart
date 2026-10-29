import 'package:flutter/material.dart';
import '../core/text/language_identity.dart';

class AppTypography {
  // Existing static styles
  static const TextStyle label =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  static const TextStyle display =
      TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const TextStyle title =
      TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const TextStyle h1 =
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle h2 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle body =
      TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const TextStyle caption =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w300);

  /// Returns safe font settings based on the language profile with appropriate fallbacks
  static TextStyle getSafeStyle(LanguageIdentity identity,
      {double fontSize = 16.0, Color? color}) {
    List<String> fallbacks =
        _getFallbacksForProfile(identity.typographyProfile);

    if (identity.typographyProfile == 'cairo') {
      return TextStyle(
        fontFamily: 'Cairo',
        fontFamilyFallback: fallbacks,
        fontSize: fontSize,
        height: 1.45,
        color: color ?? Colors.white,
      );
    }

    return TextStyle(
      fontFamilyFallback: fallbacks,
      fontSize: fontSize,
      height: 1.2,
      color: color ?? Colors.white,
    );
  }

  static List<String> _getFallbacksForProfile(String typographyProfile) {
    switch (typographyProfile) {
      case 'cairo':
      case 'arabic':
        return ['NotoSansArabic'];
      case 'hebrew':
        return ['NotoSansHebrew'];
      case 'devanagari':
        return ['NotoSansDevanagari'];
      case 'ethiopic':
        return ['NotoSansEthiopic'];
      case 'georgian':
        return ['NotoSansGeorgian'];
      case 'armenian':
        return ['NotoSansArmenian'];
      case 'cjk':
        return ['NotoSansSC'];
      default:
        // No eager loading of fonts - rely on system defaults if not explicitly supported
        return [];
    }
  }

  /// Wraps text with strict directionality to prevent punctuation flipping in mixed-script texts
  static Widget buildBiDiText(String text, LanguageIdentity identity,
      {TextStyle? style}) {
    return Directionality(
      textDirection: identity.writingDirection == WritingDirection.rtl
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Text(
        text,
        style: style ?? getSafeStyle(identity),
        textAlign: identity.writingDirection == WritingDirection.rtl
            ? TextAlign.right
            : TextAlign.left,
      ),
    );
  }

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
