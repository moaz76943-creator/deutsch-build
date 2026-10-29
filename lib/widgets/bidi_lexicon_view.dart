import 'package:flutter/material.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ResilientTextContainer(
        child: LexiconRichDetails(entry: entry),
      ),
    );
  }
}
