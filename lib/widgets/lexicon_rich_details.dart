import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';
import 'accessible_multilingual_text.dart';

class LexiconRichDetails extends StatelessWidget {
  final String? partOfSpeech;
  final String? gender;
  final String? pluralForm;
  final String? ipa;
  final String? explanation;
  final String explanationLanguageCode;

  const LexiconRichDetails({
    super.key,
    this.partOfSpeech,
    this.gender,
    this.pluralForm,
    this.ipa,
    this.explanation,
    this.explanationLanguageCode = 'ar',
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> details = [];

    if (partOfSpeech != null && partOfSpeech!.isNotEmpty) {
      details.add(_buildDetailItem('POS: ', partOfSpeech!));
    }

    if (gender != null && gender!.isNotEmpty) {
      details.add(_buildDetailItem('Gender: ', gender!));
    }

    if (pluralForm != null && pluralForm!.isNotEmpty) {
      details.add(_buildDetailItem('Plural: ', pluralForm!));
    }

    if (ipa != null && ipa!.isNotEmpty) {
      details.add(
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '/$ipa/',
              style: AppTypography.label, // Fallback since caption isn't there
            ),
          ),
        ),
      );
    }

    if (explanation != null && explanation!.isNotEmpty) {
      details.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: AccessibleMultilingualText(
            text: explanation!,
            languageCode: explanationLanguageCode,
            style: AppTypography.body,
          ),
        ),
      );
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: details,
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Text(
        '$label$value',
        style: AppTypography.label, // Fallback since caption isn't there
      ),
    );
  }
}
