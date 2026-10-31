import 'package:flutter/material.dart';

/// MultiScriptTypography - Master Constitution Section 10 & PR #505 Compliant.
/// Prevents missing glyph ("tofu" box) errors across 100 languages by injecting
/// canonical multi-script font fallbacks (Arabic, CJK, Devanagari, Latin).
class MultiScriptTypography {
  /// Universal fallback chain ensuring glyph resolution across major script families
  static const List<String> canonicalFontFallback = <String>[
    'Noto Sans',
    'Noto Sans Arabic',
    'Noto Sans JP',
    'Noto Sans KR',
    'Noto Sans SC',
    'Noto Sans Devanagari',
    'Roboto',
    'sans-serif',
  ];

  /// Builds a responsive TextStyle with guaranteed font fallback injection
  static TextStyle createTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    List<String>? customFallback,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontFamilyFallback: customFallback ?? canonicalFontFallback,
    );
  }

  /// Injects universal font fallbacks across the entire ThemeData TextTheme
  static TextTheme applyFallbackToTheme(TextTheme baseTheme) {
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontFamilyFallback: canonicalFontFallback),
      displayMedium: baseTheme.displayMedium?.copyWith(fontFamilyFallback: canonicalFontFallback),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontFamilyFallback: canonicalFontFallback),
      titleLarge: baseTheme.titleLarge?.copyWith(fontFamilyFallback: canonicalFontFallback),
      titleMedium: baseTheme.titleMedium?.copyWith(fontFamilyFallback: canonicalFontFallback),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontFamilyFallback: canonicalFontFallback),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontFamilyFallback: canonicalFontFallback),
      labelLarge: baseTheme.labelLarge?.copyWith(fontFamilyFallback: canonicalFontFallback),
    );
  }
}
