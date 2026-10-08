import 'package:flutter/material.dart';

class AppDirectionalText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection textDirection;

  const AppDirectionalText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.textDirection = TextDirection.ltr,
  });

  factory AppDirectionalText.arabic(String text, {TextStyle? style, TextAlign? textAlign}) {
    return AppDirectionalText(
      text: text,
      style: style,
      textAlign: textAlign ?? TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  factory AppDirectionalText.target(String text, {TextStyle? style, TextAlign? textAlign}) {
    return AppDirectionalText(
      text: text,
      style: style,
      textAlign: textAlign ?? TextAlign.left,
      textDirection: TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: Text(
        text,
        textAlign: textAlign,
        style: style,
      ),
    );
  }
}
