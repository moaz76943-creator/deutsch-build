import 'package:flutter/material.dart';

/// مكوّن نصوص يضمن عزل اتجاه النصوص المتعددة اللغات دون التأثير على اتجاه الصفحة
class AppDirectionalText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextDirection? forceDirection;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppDirectionalText(
    this.text, {
    super.key,
    this.style,
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
    final effectiveDirection = forceDirection ??
        (_isRTL(text) ? TextDirection.rtl : TextDirection.ltr);

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
