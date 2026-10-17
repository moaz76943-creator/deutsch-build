import 'package:flutter/material.dart';
<<<<<<< HEAD
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
=======
import 'bidi_lexicon_view.dart';
import 'resilient_text_container.dart';

class LexiconRichDetails extends StatelessWidget {
  final String term;
  final String termLocale;
  final String translation;
  final String translationLocale;
  final String? example;
  final String? exampleTranslation;
  final String? partOfSpeech;

  const LexiconRichDetails({
    super.key,
    required this.term,
    required this.termLocale,
    required this.translation,
    required this.translationLocale,
    this.example,
    this.exampleTranslation,
    this.partOfSpeech,
  });

  @override
  Widget build(BuildContext context) {
    return ResilientTextContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (partOfSpeech != null) ...[
            Text(
              partOfSpeech!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
          ],
          BidiLexiconView(
            sourceText: term,
            sourceLocale: termLocale,
            targetText: translation,
            targetLocale: translationLocale,
            sourceStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            targetStyle: const TextStyle(fontSize: 18),
          ),
          if (example != null && exampleTranslation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: BidiLexiconView(
                sourceText: example!,
                sourceLocale: termLocale,
                targetText: exampleTranslation!,
                targetLocale: translationLocale,
                sourceStyle: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                targetStyle: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ],
      ),
>>>>>>> origin/main
    );
  }
}
