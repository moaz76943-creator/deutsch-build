import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../core/lexical_repository.dart';
import 'lexicon_rich_details.dart';
import 'resilient_text_container.dart';

/// A complete view for a lexical entry, safely rendering BiDi and rich text,
/// preventing overflow using [ResilientTextContainer].
class BidiLexiconView extends StatelessWidget {
  final LexicalEntry entry;
  final EdgeInsetsGeometry padding;

  const BidiLexiconView({
    super.key,
    required this.entry,
    this.padding = const EdgeInsets.all(16.0),
=======
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
>>>>>>> origin/main
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Padding(
      padding: padding,
      child: ResilientTextContainer(
        child: LexiconRichDetails(entry: entry),
      ),
=======
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
>>>>>>> origin/main
    );
  }
}
