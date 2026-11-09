export 'widgets/app_directional_text.dart';

import 'package:flutter/material.dart';
import '../core/text/language_identity.dart';

class AppTypography {
  static const List<String> fallbackFontFamilies = ['NotoSansArabic'];

  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFamily: 'Cairo',
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    fontFamily: 'Cairo',
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFamily: 'Cairo',
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    fontFamily: 'Cairo',
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
    fontFamily: 'Cairo',
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    fontFamily: 'Cairo',
  );

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
        return ['Cairo'];
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
}
