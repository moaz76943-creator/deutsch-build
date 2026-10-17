import 'package:flutter/material.dart';
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
    );
  }
}
