import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';
import 'resilient_text_container.dart';
import 'accessible_multilingual_text.dart';

class LexiconRichDetails extends StatelessWidget {
  final LexicalEntry entry;

  const LexiconRichDetails({
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
          if (entry.partOfSpeech.isNotEmpty) ...[
            AccessibleMultilingualText(
              entry.partOfSpeech,
              locale: entry.targetLocale,
              style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
              semanticLabel: 'Part of Speech: ${entry.partOfSpeech}',
            ),
            const SizedBox(height: 8.0),
          ],
          if (entry.targetExample.isNotEmpty) ...[
            AccessibleMultilingualText(
              entry.targetExample,
              locale: entry.targetLocale,
              style: AppTypography.body,
              semanticLabel: 'Example: ${entry.targetExample}',
            ),
            const SizedBox(height: 4.0),
          ],
          if (entry.sourceExampleTranslation.isNotEmpty) ...[
            AccessibleMultilingualText(
              entry.sourceExampleTranslation,
              locale: entry.sourceLocale,
              style: AppTypography.body.copyWith(color: Colors.grey.shade700),
              semanticLabel: 'Example Translation: ${entry.sourceExampleTranslation}',
            ),
          ],
        ],
      ),
    );
  }
}
