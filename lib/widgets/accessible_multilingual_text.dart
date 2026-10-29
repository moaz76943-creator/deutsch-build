import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/bidi_helper.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/design_system/widgets/app_directional_text.dart';

class AccessibleMultilingualText extends StatelessWidget {
  final String text;
  final String languageCode;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;
  final bool protectPunctuation;

  const AccessibleMultilingualText({
    super.key,
    required this.text,
    required this.languageCode,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    this.protectPunctuation = true,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final direction = LanguageBiDiHelper.getDirection(languageCode);
    final isRtl = direction == TextDirection.rtl;

    String displayText = text;
    if (protectPunctuation) {
      displayText = isRtl ? BiDiHelper.wrapRtl(text) : BiDiHelper.wrapLtr(text);
    }

    return Semantics(
      label: semanticLabel ?? text,
      textDirection: direction,
      child: AppDirectionalText(
        displayText,
        style: (style ?? const TextStyle()).copyWith(
          height:
              style?.height ?? LanguageBiDiHelper.getLineHeight(languageCode),
        ),
        forceDirection: direction,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
