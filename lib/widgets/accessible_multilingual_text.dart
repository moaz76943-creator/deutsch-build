import 'package:flutter/material.dart';
import '../core/language_bidi_helper.dart';
import '../core/design/bidi_text_isolator.dart';

class AccessibleMultilingualText extends StatelessWidget {
  final String text;
  final String locale;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  const AccessibleMultilingualText(
    this.text, {
    super.key,
    required this.locale,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
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
        ),
      ),
    );
  }
}
