import 'package:flutter/material.dart';
import '../core/language_bidi_helper.dart';
import '../core/design/bidi_text_isolator.dart';

class AccessibleMultilingualText extends StatelessWidget {
  final String text;
<<<<<<< HEAD
  final String bcp47Code;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;
=======
  final String locale;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;
>>>>>>> origin/main

  const AccessibleMultilingualText(
    this.text, {
    super.key,
<<<<<<< HEAD
    required this.bcp47Code,
    this.style,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
=======
    required this.locale,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
>>>>>>> origin/main
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final direction = LanguageBiDiHelper.getDirection(bcp47Code);
    final lineHeight = LanguageBiDiHelper.getLineHeight(bcp47Code);
    final isRtl = direction == TextDirection.rtl;

    // Isolate text to prevent punctuation bleeding and guarantee correct rendering
    final isolatedText = BiDiTextIsolator.wrapDirectional(text, isRtl: isRtl);

    return Directionality(
      textDirection: direction,
      child: Text(
        isolatedText,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.visible,
        semanticsLabel: semanticLabel ?? text,
        style: (style ?? const TextStyle()).copyWith(
          height: lineHeight,
=======
    final direction = LanguageBiDiHelper.getDirection(locale);
    final lineHeight = LanguageBiDiHelper.getLineHeight(locale);
    final isRtl = direction == TextDirection.rtl;
    final wrappedText = BiDiTextIsolator.wrapDirectional(text, isRtl: isRtl);

    return Directionality(
      textDirection: direction,
      child: Semantics(
        label: semanticsLabel ?? text,
        textDirection: direction,
        child: Text(
          wrappedText,
          style: (style ?? const TextStyle()).copyWith(height: lineHeight),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
>>>>>>> origin/main
        ),
      ),
    );
  }
}
