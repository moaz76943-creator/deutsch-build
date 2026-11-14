import 'package:flutter/material.dart';
import 'accessible_multilingual_text.dart';
import 'resilient_text_container.dart';
import 'lexicon_rich_details.dart';

class BidiLexiconView extends StatelessWidget {
  final String sourceText;
  final String sourceLanguageCode;
  final String targetText;
  final String targetLanguageCode;

  final String? partOfSpeech;
  final String? gender;
  final String? pluralForm;
  final String? ipa;
  final String? explanation;

  const BidiLexiconView({
    super.key,
    required this.sourceText,
    required this.sourceLanguageCode,
    required this.targetText,
    required this.targetLanguageCode,
    this.partOfSpeech,
    this.gender,
    this.pluralForm,
    this.ipa,
    this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return ResilientTextContainer(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AccessibleMultilingualText(
            text: sourceText,
            languageCode: sourceLanguageCode,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8.0),
          LexiconRichDetails(
            partOfSpeech: partOfSpeech,
            gender: gender,
            pluralForm: pluralForm,
            ipa: ipa,
            explanation: explanation,
            explanationLanguageCode: targetLanguageCode,
          ),
          const SizedBox(height: 12.0),
          const Divider(),
          const SizedBox(height: 12.0),
          AccessibleMultilingualText(
            text: targetText,
            languageCode: targetLanguageCode,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
