import 'package:flutter/material.dart';

/// Languages with productive numeral classifiers or measure words.
///
/// Classifiers are supplied by the lexicon, not inferred from the noun:
/// different senses and contexts can require different classifiers.
const Set<String> _measureWordLanguages = <String>{
  'zh', 'cmn', 'yue', 'ja', 'ko', 'vi', 'th', 'km', 'lo', 'my',
};

/// Selected Bantu languages whose nouns belong to agreement classes.
/// These are noun-class markers, not Asian-style counting classifiers.
const Set<String> _nounClassLanguages = <String>{
  'sw', 'zu', 'xh', 'rw', 'rn', 'lg', 'sn', 'ny', 'st', 'tn', 'ts',
  'ss', 've', 'nr', 'nso', 'ki', 'kg', 'ln',
};

/// Displays a lexical classifier beside a noun, with optional reading
/// and explanation in a tap-to-open details dialog.
///
/// Pass classifier metadata from the language-specific content layer.
/// For Bantu languages [classifier] is the noun-class marker or prefix.
/// For Asian languages it is the counter or measure word. No noun class or
/// counter is guessed when the content layer provides no classifier.
class NounClassifierView extends StatelessWidget {
  const NounClassifierView({
    super.key,
    required this.noun,
    required this.languageCode,
    required this.partOfSpeech,
    required this.classifier,
    this.reading = '',
    this.explanation = '',
  });

  final String noun;
  final String languageCode;
  final String partOfSpeech;
  final String classifier;
  final String reading;
  final String explanation;

  bool get _isNoun {
    final value = partOfSpeech.trim().toLowerCase();
    return value == 'noun' ||
        value == 'n' ||
        value == 'n.' ||
        value == 'common noun' ||
        value == 'proper noun';
  }

  String get _primaryLanguage =>
      languageCode.trim().toLowerCase().split(RegExp(r'[-_]')).first;

  @override
  Widget build(BuildContext context) {
    final language = _primaryLanguage;
    final isNounClass = _nounClassLanguages.contains(language);
    final isMeasureWord = _measureWordLanguages.contains(language);
    final nounText = noun.trim();
    final classifierText = classifier.trim();

    if (!_isNoun ||
        (!isNounClass && !isMeasureWord) ||
        nounText.isEmpty ||
        classifierText.isEmpty) {
      return const SizedBox.shrink();
    }

    final label = isNounClass ? 'Noun class' : 'Measure word';
    final readingText = reading.trim();
    final explanationText = explanation.trim();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(nounText, textDirection: TextDirection.ltr),
        ActionChip(
          key: const Key('nounClassifierBadge'),
          tooltip: 'Show reading and explanation',
          label: Text(
            '$label: $classifierText',
            textDirection: TextDirection.ltr,
          ),
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(label),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        nounText,
                        textDirection: TextDirection.ltr,
                        style: Theme.of(dialogContext).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(classifierText, textDirection: TextDirection.ltr),
                      if (readingText.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          'Reading: $readingText',
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                      if (explanationText.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(explanationText),
                      ],
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
