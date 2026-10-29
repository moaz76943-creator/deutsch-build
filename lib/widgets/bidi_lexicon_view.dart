import 'package:flutter/material.dart';
import 'accessible_multilingual_text.dart';

class BidiLexiconView extends StatelessWidget {
  final String sourceText;
  final String sourceLocale;
  final String targetText;
  final String targetLocale;
  final TextStyle? sourceStyle;
  final TextStyle? targetStyle;

  const BidiLexiconView({
    super.key,
    required this.sourceText,
    required this.sourceLocale,
    required this.targetText,
    required this.targetLocale,
    this.sourceStyle,
    this.targetStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccessibleMultilingualText(
          sourceText,
          locale: sourceLocale,
          style: sourceStyle,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 8),
        AccessibleMultilingualText(
          targetText,
          locale: targetLocale,
          style: targetStyle,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
