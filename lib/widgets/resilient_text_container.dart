import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Width-aware text for long Latin compounds and mixed-script lexicon fields.
/// Only long Latin runs receive optional soft-hyphen break opportunities.
/// The original string is preserved for accessibility.
class ResilientTextContainer extends StatelessWidget {
  const ResilientTextContainer({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.enableSoftHyphens = true,
  });

  final String? text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool enableSoftHyphens;

  static final RegExp _longLatinRun =
      RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿ]{15,}');

  /// Non-destructive discretionary breaks. BiDi/IPA/CJK content is unchanged.
  static String wrapCompounds(String original) {
    return original.replaceAllMapped(_longLatinRun, (match) {
      final run = match.group(0)!;
      final buffer = StringBuffer();
      for (var i = 0; i < run.length; i++) {
        if (i > 0 && i % 10 == 0) buffer.write('\u00AD');
        buffer.write(run[i]);
      }
      return buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final original = text ?? '';
    if (original.trim().isEmpty) return const SizedBox.shrink();
    final displayed = enableSoftHyphens ? wrapCompounds(original) : original;
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = MediaQuery.sizeOf(context).width;
        final bound = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : math.max(1.0, viewportWidth - 32.0);
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: bound),
          child: Text(
            displayed,
            style: style,
            maxLines: maxLines,
            softWrap: true,
            overflow: maxLines == null
                ? TextOverflow.clip
                : TextOverflow.ellipsis,
            textAlign: textAlign,
            textDirection: textDirection,
            semanticsLabel: original,
          ),
        );
      },
    );
  }
}
