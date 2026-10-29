import 'package:flutter/material.dart';
import 'multi_script_typography.dart';

class AppTypography {
  static const TextStyle label = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

  static const TextStyle display = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const TextStyle title = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const TextStyle h1 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle body = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w300);

  static Widget multiScriptText(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return ScriptAwareText(
      text,
      key: key,
      style: style ?? AppTypography.body,
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
