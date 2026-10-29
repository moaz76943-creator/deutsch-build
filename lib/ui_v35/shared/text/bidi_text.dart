import 'package:flutter/material.dart';

import '../../../core/language/app_text_direction.dart';
import '../../../core/text/directional_text.dart';

TextDirection flutterTextDirection(AppTextDirection direction) =>
    switch (direction) {
      AppTextDirection.ltr => TextDirection.ltr,
      AppTextDirection.rtl => TextDirection.rtl,
    };

class BidiText extends StatelessWidget {
  const BidiText(
    this.value, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  });

  final DirectionalText value;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Text(
        value.text,
        textDirection: flutterTextDirection(value.direction),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        semanticsLabel: semanticsLabel,
      );
}
