import 'package:flutter/material.dart';

import '../../../core/text/bidi_boundary.dart';
import '../../../core/text/directional_text.dart';

final class LinguisticTextSpan {
  const LinguisticTextSpan(this.value, {this.style, this.semanticsLabel});

  final DirectionalText value;
  final TextStyle? style;
  final String? semanticsLabel;

  TextSpan toTextSpan() => TextSpan(
        text: BidiBoundary.isolate(value),
        style: style,
        semanticsLabel: semanticsLabel,
      );
}
