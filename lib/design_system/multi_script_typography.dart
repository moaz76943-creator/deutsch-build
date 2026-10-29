import 'package:flutter/material.dart';

class MultiScriptTypography {
  static const String arabicFallback = 'Cairo'; // using existing Cairo
  static const String hebrewFallback = 'NotoSansHebrew';
  static const String devanagariFallback = 'NotoSansDevanagari';
  static const String ethiopicFallback = 'NotoSansEthiopic';
  static const String scFallback = 'NotoSansSC';
  static const String jpFallback = 'NotoSansJP';
  static const String krFallback = 'NotoSansKR';
  static const String georgianFallback = 'NotoSansGeorgian';
  static const String armenianFallback = 'NotoSansArmenian';

  static List<String> getFallbacksForText(String text) {
    final fallbacks = <String>{};

    for (final rune in text.runes) {
      if ((rune >= 0x0600 && rune <= 0x06FF) ||
          (rune >= 0x0750 && rune <= 0x077F) ||
          (rune >= 0x08A0 && rune <= 0x08FF)) {
        fallbacks.add(arabicFallback);
      } else if (rune >= 0x0590 && rune <= 0x05FF) {
        fallbacks.add(hebrewFallback);
      } else if (rune >= 0x0900 && rune <= 0x097F) {
        fallbacks.add(devanagariFallback);
      } else if ((rune >= 0x1200 && rune <= 0x137F) ||
          (rune >= 0x1380 && rune <= 0x139F) ||
          (rune >= 0x2D80 && rune <= 0x2DDF)) {
        fallbacks.add(ethiopicFallback);
      } else if (rune >= 0x10A0 && rune <= 0x10FF) {
        fallbacks.add(georgianFallback);
      } else if (rune >= 0x0530 && rune <= 0x058F) {
        fallbacks.add(armenianFallback);
      } else if ((rune >= 0x3040 && rune <= 0x309F) ||
          (rune >= 0x30A0 && rune <= 0x30FF)) {
        fallbacks.add(jpFallback);
      } else if ((rune >= 0xAC00 && rune <= 0xD7AF) ||
          (rune >= 0x1100 && rune <= 0x11FF) ||
          (rune >= 0x3130 && rune <= 0x318F)) {
        fallbacks.add(krFallback);
      } else if ((rune >= 0x4E00 && rune <= 0x9FFF) ||
          (rune >= 0x3400 && rune <= 0x4DBF) ||
          (rune >= 0x20000 && rune <= 0x2A6DF)) {
        fallbacks.add(scFallback);
      }
    }

    return fallbacks.toList();
  }
}

class ScriptAwareText extends StatelessWidget {
  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow? overflow;

  const ScriptAwareText(
    String this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.overflow,
  }) : textSpan = null;

  const ScriptAwareText.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.overflow,
  }) : data = null;

  String _extractText(InlineSpan span) {
    if (span is TextSpan) {
      final buffer = StringBuffer(span.text ?? '');
      if (span.children != null) {
        for (final child in span.children!) {
          buffer.write(_extractText(child));
        }
      }
      return buffer.toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final textContent =
        data ?? (textSpan != null ? _extractText(textSpan!) : '');
    final fallbacks = MultiScriptTypography.getFallbacksForText(textContent);

    TextStyle effectiveStyle = style ?? const TextStyle();
    if (fallbacks.isNotEmpty) {
      final existingFallbacks = effectiveStyle.fontFamilyFallback ?? [];
      final newFallbacks = <String>[...existingFallbacks];
      for (final fallback in fallbacks) {
        if (!newFallbacks.contains(fallback)) {
          newFallbacks.add(fallback);
        }
      }
      effectiveStyle =
          effectiveStyle.copyWith(fontFamilyFallback: newFallbacks);
    }

    if (data != null) {
      return Text(
        data!,
        style: effectiveStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: maxLines,
        overflow: overflow,
      );
    } else {
      return Text.rich(
        textSpan!,
        style: effectiveStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
  }
}
