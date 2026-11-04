import 'package:flutter/material.dart';
import '../../core/language_bidi_helper.dart';

/// Shared locale direction API for typography and dashboard consumers.
class AppTextDirection {
  static TextDirection forLanguageCode(String languageCode) =>
      LanguageBiDiHelper.getDirection(languageCode.trim().replaceAll('_', '-'));
}

/// مكوّن نصوص يضمن عزل اتجاه النصوص المتعددة اللغات دون التأثير على اتجاه الصفحة
class AppDirectionalText extends StatelessWidget {
  final String text;
  final String? languageCode;
  final TextStyle? style;
  final TextDirection? forceDirection;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppDirectionalText(
    this.text, {
    super.key,
    this.style,
    this.languageCode,
    this.forceDirection,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  bool _isRTL(String input) {
    if (input.trim().isEmpty) return false;
    final firstRune = input.trim().runes.first;
    return (firstRune >= 0x0590 && firstRune <= 0x08FF);
  }

  @override
  Widget build(BuildContext context) {
    final code = languageCode?.trim().replaceAll('_', '-');
    final effectiveDirection = forceDirection ??
        (code != null && code.isNotEmpty
            ? AppTextDirection.forLanguageCode(code)
            : (_isRTL(text) ? TextDirection.rtl : TextDirection.ltr));

    return Directionality(
      textDirection: effectiveDirection,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
