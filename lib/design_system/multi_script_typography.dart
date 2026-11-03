import 'package:flutter/material.dart';

/// MultiScriptTypography - Master Constitution Section 10 & PR #505 Compliant.
/// Prevents missing glyph ("tofu" box) errors across 100 languages by injecting
/// canonical multi-script font fallbacks (Arabic, CJK, Devanagari, Latin).
class MultiScriptTypography {
  static const String arabicFallback = 'NotoSansArabic';
  static const String hebrewFallback = 'NotoSansHebrew';
  static const String devanagariFallback = 'NotoSansDevanagari';
  static const String ethiopicFallback = 'NotoSansEthiopic';
  static const String georgianFallback = 'NotoSansGeorgian';
  static const String armenianFallback = 'NotoSansArmenian';
  static const String scFallback = 'NotoSansSC';
  static const String jpFallback = 'NotoSansJP';
  static const String krFallback = 'NotoSansKR';

  /// Universal fallback chain ensuring glyph resolution across major script families
  static const List<String> canonicalFontFallback = <String>[
    'NotoSansArabic',
    'NotoSansJP',
    'NotoSansKR',
    'NotoSansSC',
    'NotoSansDevanagari',
    'Roboto',
    'sans-serif',
  ];

  static List<String> getFallbacksForText(String text) {
    List<String> fallbacks = [];

    // Arabic / Persian / Urdu (0600–06FF, 0750–077F, 08A0–08FF)
    if (RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(text)) {
      fallbacks.add('Cairo');
      fallbacks.add(arabicFallback);
    }
    // Hebrew (0590–05FF)
    if (RegExp(r'[\u0590-\u05FF]').hasMatch(text)) {
      fallbacks.add(hebrewFallback);
    }
    // Devanagari (0900–097F)
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      fallbacks.add(devanagariFallback);
    }
    // Ethiopic (1200–137F, 1380–139F, 2D80–2DDF, AB00–AB2F)
    if (RegExp(r'[\u1200-\u137F\u1380-\u139F\u2D80-\u2DDF\uAB00-\uAB2F]').hasMatch(text)) {
      fallbacks.add(ethiopicFallback);
    }
    // Georgian (10A0–10FF, 2D00–2D2F)
    if (RegExp(r'[\u10A0-\u10FF\u2D00-\u2D2F]').hasMatch(text)) {
      fallbacks.add(georgianFallback);
    }
    // Armenian (0530–058F)
    if (RegExp(r'[\u0530-\u058F]').hasMatch(text)) {
      fallbacks.add(armenianFallback);
    }
    // CJK Unified Ideographs (4E00–9FFF) - Simplified Chinese
    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(text)) {
      fallbacks.add(scFallback);
    }
    // Hiragana/Katakana (3040–30FF) - Japanese
    if (RegExp(r'[\u3040-\u309F\u30A0-\u30FF]').hasMatch(text)) {
      fallbacks.add(jpFallback);
    }
    // Hangul (AC00–D7AF, 1100–11FF) - Korean
    if (RegExp(r'[\uAC00-\uD7AF\u1100-\u11FF]').hasMatch(text)) {
      fallbacks.add(krFallback);
    }

    return fallbacks.isEmpty ? [] : fallbacks;
  }

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

class ScriptAwareText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final InlineSpan? textSpan;

  const ScriptAwareText(
    this.text, {
    super.key,
    this.style,
    this.textDirection,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : textSpan = null;

  const ScriptAwareText.rich(
    this.textSpan, {
    super.key,
    this.style,
    this.textDirection,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : text = '';

  @override
  Widget build(BuildContext context) {
    if (textSpan != null) {
      String extractText(InlineSpan span) {
        if (span is TextSpan) {
          String t = span.text ?? '';
          if (span.children != null) {
            for (var child in span.children!) {
              t += extractText(child);
            }
          }
          return t;
        }
        return '';
      }

      final textContent = extractText(textSpan!);
      final fallbacks = MultiScriptTypography.getFallbacksForText(textContent);

      final effectiveStyle = style ?? const TextStyle();
      final finalStyle = effectiveStyle.copyWith(
        fontFamilyFallback: fallbacks.isNotEmpty ? (effectiveStyle.fontFamilyFallback != null ? [...effectiveStyle.fontFamilyFallback!, ...fallbacks] : fallbacks) : effectiveStyle.fontFamilyFallback,
      );

      return RichText(
        text: TextSpan(
          style: finalStyle,
          children: [textSpan!],
        ),
        textDirection: textDirection,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.clip,
        textAlign: textAlign ?? TextAlign.start,
      );
    }

    final fallbacks = MultiScriptTypography.getFallbacksForText(text);

    final effectiveStyle = style ?? const TextStyle();
    final finalStyle = fallbacks.isNotEmpty ? effectiveStyle.copyWith(
      fontFamilyFallback: effectiveStyle.fontFamilyFallback != null
        ? [...effectiveStyle.fontFamilyFallback!, ...fallbacks]
        : fallbacks,
    ) : effectiveStyle;

    return Text(
      text,
      style: finalStyle.fontFamilyFallback != null ? finalStyle : style,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
