export 'package:flutter/material.dart';
import 'package:flutter/material.dart';

export '../../design_system/app_typography.dart' show AppDirectionalText;

class LifeFeatureText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const LifeFeatureText(this.text, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style, textAlign: textAlign);
  }
}
