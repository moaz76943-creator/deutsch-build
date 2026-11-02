import 'package:flutter/material.dart';
import 'font_fallback_engine.dart';

/// MultiScriptTypography - Master Constitution Section 10 & PR #505 Compliant.
/// Prevents missing glyph ("tofu" box) errors across 100 languages by injecting
/// canonical multi-script font fallbacks (Arabic, CJK, Devanagari, Latin).
class MultiScriptTypography {
  static const String arabicFallback = 'Cairo';
  static const String hebrewFallback = 'NotoSansHebrew';
  static const String devanagariFallback = 'NotoSansDevanagari';
  static const String ethiopicFallback = 'NotoSansEthiopic';
  static const String georgianFallback = 'NotoSansGeorgian';
  static const String armenianFallback = 'NotoSansArmenian';
  static const String scFallback = 'NotoSansSC';
  static const String jpFallback = 'NotoSansJP';
  static const String krFallback = 'NotoSansKR';

  /// Universal fallback chain ensuring glyph resolution across major script families
  static const List<String> canonicalFontFallback = FontFallbackEngine.universalFallback;

  static List<String> getFallbacksForText(String text) {
    return FontFallbackEngine.getFallbackForText(text);
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
  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const ScriptAwareText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  }) : textSpan = null;

  const ScriptAwareText.rich(
    this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  }) : data = null;

  List<String> _extractTextForSpan(InlineSpan span) {
    List<String> texts = [];
    span.visitChildren((child) {
      if (child is TextSpan && child.text != null) {
        texts.add(child.text!);
      }
      return true;
    });
    return texts;
  }

  @override
  Widget build(BuildContext context) {
    String allText = '';
    if (data != null) {
      allText = data!;
    } else if (textSpan != null) {
      allText = _extractTextForSpan(textSpan!).join();
    }

    final fallbacks = MultiScriptTypography.getFallbacksForText(allText);

    TextStyle effectiveStyle = style ?? const TextStyle();
    if (fallbacks.isNotEmpty) {
      List<String> existingFallbacks = effectiveStyle.fontFamilyFallback ?? [];
      List<String> combined = [...existingFallbacks];
      for (var f in fallbacks) {
        if (!combined.contains(f)) {
          combined.add(f);
        }
      }
      effectiveStyle = effectiveStyle.copyWith(fontFamilyFallback: combined);
    }

    if (data != null) {
      // ignore: deprecated_member_use
      return Text(
        data!,
        style: effectiveStyle,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        // ignore: deprecated_member_use
        textScaleFactor: textScaleFactor,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
      );
    } else {
      return RichText(
        text: TextSpan(
          style: effectiveStyle,
          children: [textSpan!],
        ),
        textAlign: textAlign ?? TextAlign.start,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap ?? true,
        overflow: overflow ?? TextOverflow.clip,
        // ignore: deprecated_member_use
        textScaleFactor: textScaleFactor ?? 1.0,
        textScaler: textScaler ?? TextScaler.noScaling,
        maxLines: maxLines,
        textWidthBasis: textWidthBasis ?? TextWidthBasis.parent,
        textHeightBehavior: textHeightBehavior,
      );
    }
  }
}
