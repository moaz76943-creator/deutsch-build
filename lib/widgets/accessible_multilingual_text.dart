import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/widgets/app_directional_text.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/core/design/bidi_text_isolator.dart';

class AccessibleMultilingualText extends StatelessWidget {
  final String text;
  final String locale;
  final TextStyle? style;
  final String? semanticLabel;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AccessibleMultilingualText(
    this.text, {
    super.key,
    required this.locale,
    this.style,
    this.semanticLabel,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final direction = LanguageBiDiHelper.getDirection(locale);
    final isRtl = direction == TextDirection.rtl;
    final lineHeight = LanguageBiDiHelper.getLineHeight(locale);

    // Protect text selection, URLs and embedded punctuation using isolation markers.
    final isolatedText = BiDiTextIsolator.wrapDirectional(text, isRtl: isRtl);

    final defaultStyle = style ?? const TextStyle();
    final combinedStyle = defaultStyle.copyWith(
      height: defaultStyle.height ?? lineHeight,
    );

    return Semantics(
      label: semanticLabel ?? text,
      textDirection: direction,
      child: ExcludeSemantics(
        child: AppDirectionalText(
          isolatedText,
          style: combinedStyle,
          forceDirection: direction,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        ),
      ),
    );
  }
}
