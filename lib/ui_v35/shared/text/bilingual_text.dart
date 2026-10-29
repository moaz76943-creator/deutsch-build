import 'package:flutter/material.dart';

import '../../../core/language/app_text_direction.dart';
import '../../../core/text/directional_text.dart';
import 'bidi_text.dart';
import 'linguistic_text_span.dart';

class BilingualText extends StatelessWidget {
  const BilingualText({
    super.key,
    required this.segments,
    this.baseDirection = AppTextDirection.rtl,
    this.style,
    this.textAlign,
  });

  final List<DirectionalText> segments;
  final AppTextDirection baseDirection;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(
          style: style,
          children: segments
              .map((segment) => LinguisticTextSpan(segment).toTextSpan())
              .toList(growable: false),
        ),
        textDirection: flutterTextDirection(baseDirection),
        textAlign: textAlign,
      );
}
