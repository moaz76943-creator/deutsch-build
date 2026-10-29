import 'package:flutter/material.dart';
import '../core/language_bidi_helper.dart';
import '../core/design/bidi_text_isolator.dart';

class AccessibleMultilingualText extends StatelessWidget {
  final String text;
  final String bcp47Code;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;

  const AccessibleMultilingualText(
    this.text, {
    super.key,
    required this.bcp47Code,
    this.style,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
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
        ),
      ),
    );
  }
}
