import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';
import 'resilient_text_container.dart';
import 'accessible_multilingual_text.dart';

class BidiLexiconView extends StatelessWidget {
  final LexicalEntry entry;

  const BidiLexiconView({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return ResilientTextContainer(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AccessibleMultilingualText(
            entry.targetTerm,
            locale: entry.targetLocale,
            style: AppTypography.h2,
            semanticLabel: 'Term: ${entry.targetTerm}',
          ),
          const SizedBox(height: 8.0),
          AccessibleMultilingualText(
            entry.sourceMeaning,
            locale: entry.sourceLocale,
            style: AppTypography.body,
            semanticLabel: 'Meaning: ${entry.sourceMeaning}',
          ),
        ],
      ),
    );
  }
}
