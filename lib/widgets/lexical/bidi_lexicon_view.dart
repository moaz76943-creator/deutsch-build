import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';
import 'accessible_multilingual_text.dart';
import 'resilient_text_container.dart';
import 'lexicon_rich_details.dart';

class BidiLexiconView extends StatelessWidget {
  final String word;
  final String? article;
  final String? plural;
  final String meaning;
  final String? example;

  const BidiLexiconView({
    super.key,
    required this.word,
    this.article,
    this.plural,
    required this.meaning,
    this.example,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResilientTextContainer(
            child: Column(
              children: [
                if (article != null && article!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      article!,
                      style:
                          AppTypography.label.copyWith(color: Colors.blue[200]),
                    ),
                  ),
                AccessibleMultilingualText(
                  word,
                  style: AppTypography.display.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                if (plural != null && plural!.isNotEmpty && plural != '-') ...[
                  const SizedBox(height: 8),
                  AccessibleMultilingualText(
                    'الجمع: \u2068$plural\u2069',
                    style: AppTypography.body.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          ResilientTextContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LexiconRichDetails(
                  title: 'المعنى',
                  content: meaning,
                  icon: Icons.translate_rounded,
                ),
                if (example != null && example!.isNotEmpty) ...[
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  LexiconRichDetails(
                    title: 'مثال',
                    content: '\u2068$example\u2069',
                    icon: Icons.format_quote_rounded,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
