import 'package:flutter/material.dart';
import 'resilient_text_container.dart';

/// Whether [langCode] normally uses right-to-left script direction.
///
/// Accepts a primary language subtag or a locale tag such as `ar-JO` or
/// `fa_IR`. The legacy aliases `iw` (Hebrew) and `ji` (Yiddish) are supported.
bool isRtlLanguage(String langCode) {
  const rtlLanguages = <String>{
    'ar', // Arabic
    'he', 'iw', // Hebrew
    'ur', // Urdu
    'fa', // Persian
    'yi', 'ji', // Yiddish
    'sd', // Sindhi
    'ps', // Pashto
    'dv', // Divehi
  };

  final primaryLanguage = langCode
      .trim()
      .toLowerCase()
      .split(RegExp(r'[-_]'))
      .first;

  return rtlLanguages.contains(primaryLanguage);
}

/// Isolate a field's text from surrounding bidirectional content.
///
/// FSI and PDI are invisible Unicode formatting characters; they do not
/// replace an explicit paragraph [TextDirection].
String _isolateBidi(String value) {
  if (value.isEmpty) return value;
  return '\u2068$value\u2069';
}

/// Displays a lexicon source word and an explanation in separate BiDi contexts.
///
/// The source uses its language's native direction, while the explanation
/// follows the ambient interface [Directionality]. Each text field is wrapped
/// with Unicode FSI/PDI isolation to stop mixed-script text and punctuation
/// from influencing adjacent content.
class BidiLexiconView extends StatelessWidget {
  const BidiLexiconView({
    super.key,
    required this.sourceWord,
    required this.sourceLanguageCode,
    required this.targetExplanation,
    this.sourceStyle,
    this.explanationStyle,
    this.phonetic,
  });

  final String sourceWord;
  final String sourceLanguageCode;
  final String targetExplanation;
  final TextStyle? sourceStyle;
  final TextStyle? explanationStyle;
  /// Optional pronunciation placed directly below the headword.
  final Widget? phonetic;

  @override
  Widget build(BuildContext context) {
    final sourceDirection = isRtlLanguage(sourceLanguageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
    final interfaceDirection = Directionality.of(context);
    final textTheme = Theme.of(context).textTheme;

    if (sourceWord.trim().isEmpty &&
        targetExplanation.trim().isEmpty &&
        phonetic == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (sourceWord.trim().isNotEmpty)
              ResilientTextContainer(
                text: _isolateBidi(sourceWord),
                textDirection: sourceDirection,
                textAlign: TextAlign.start,
                style: sourceStyle ?? textTheme.titleLarge,
                maxLines: 3,
              ),
            if (phonetic != null) ...<Widget>[
              if (sourceWord.trim().isNotEmpty)
                const SizedBox(height: 8),
              phonetic!,
            ],
            if (targetExplanation.trim().isNotEmpty) ...<Widget>[
              if (sourceWord.trim().isNotEmpty || phonetic != null)
                const SizedBox(height: 8),
              ResilientTextContainer(
                text: _isolateBidi(targetExplanation),
                textDirection: interfaceDirection,
                textAlign: TextAlign.start,
                style: explanationStyle ?? textTheme.bodyMedium,
                maxLines: 8,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
