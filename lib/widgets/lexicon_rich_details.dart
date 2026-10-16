import 'package:flutter/material.dart';
import 'accessible_multilingual_text.dart';
import '../core/lexical_repository.dart';

class LexiconRichDetails extends StatelessWidget {
  final LexicalEntry entry;

  const LexiconRichDetails({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Changed from stretch to start to prevent Infinite width constraints
      mainAxisSize: MainAxisSize.min,
      children: [
        // Target term (e.g. German word)
        AccessibleMultilingualText(
          entry.targetTerm,
          bcp47Code: entry.targetLocale,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          semanticLabel: 'Term: ${entry.targetTerm}',
        ),
        const SizedBox(height: 8),

        // Part of speech
        AccessibleMultilingualText(
          entry.partOfSpeech,
          bcp47Code: entry.targetLocale,
          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Meaning
        const Text('Meaning:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        AccessibleMultilingualText(
          entry.sourceMeaning,
          bcp47Code: entry.sourceLocale,
          style: const TextStyle(fontSize: 18),
          semanticLabel: 'Meaning: ${entry.sourceMeaning}',
        ),

        // Target Example
        if (entry.targetExample.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Example:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          AccessibleMultilingualText(
            entry.targetExample,
            bcp47Code: entry.targetLocale,
            style: const TextStyle(fontSize: 16),
            semanticLabel: 'Example: ${entry.targetExample}',
          ),
          if (entry.sourceExampleTranslation.isNotEmpty) ...[
            const SizedBox(height: 4),
            AccessibleMultilingualText(
              entry.sourceExampleTranslation,
              bcp47Code: entry.sourceLocale,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              semanticLabel: 'Example Translation: ${entry.sourceExampleTranslation}',
            ),
          ]
        ],
      ],
    );
  }
}
