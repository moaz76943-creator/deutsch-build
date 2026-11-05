export 'widgets/app_directional_text.dart';

import 'package:flutter/material.dart';
import '../core/text/language_identity.dart';

class AppTypography {
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

  static TextStyle get body => const TextStyle(
        fontFamily: 'Cairo',
        fontFamilyFallback: [
          'NotoSansHebrew',
          'NotoSansDevanagari',
          'NotoSansEthiopic',
          'NotoSansGeorgian',
          'NotoSansArmenian',
          'NotoSansCJK',
        ],
      );

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

}
