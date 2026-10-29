import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/bidi_lexicon_view.dart';
import '../widgets/phonetic_ipa_view.dart';
import '../widgets/noun_classifier_view.dart';
import '../widgets/idioms_view.dart';
import '../widgets/example_sentences_view.dart';

class AppTypography {
  static const TextStyle h1 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A));
  static const TextStyle h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B));
  static const TextStyle h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155));
  static const TextStyle body = TextStyle(fontSize: 14, color: Color(0xFF475569));
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569));
  static const TextStyle caption = TextStyle(fontSize: 12, color: Color(0xFF64748B));
  static const TextStyle label = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B));
}

class AppGradients {
  static const LinearGradient blueCard = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ArticleBadge extends StatelessWidget {
  final String? article;
  final String? label;
  final String? text;
  final Color? color;

  const ArticleBadge({
    super.key,
    this.article,
    this.label,
    this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final display = article ?? label ?? text ?? '';
    if (display.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF4F46E5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        display,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class WordDeepDiveSheet extends StatelessWidget {
  final Map<String, dynamic>? wordData;
  final String? word;
  final String? article;
  final String? meaning;
  final String? example;
  final String? exampleMeaning;
  final dynamic item;

  const WordDeepDiveSheet({
    super.key,
    this.wordData,
    this.word,
    this.article,
    this.meaning,
    this.example,
    this.exampleMeaning,
    this.item,
  });

  static Future<void> show(
    BuildContext context, {
    Map<String, dynamic>? wordData,
    String? word,
    String? article,
    String? meaning,
    String? example,
    String? exampleMeaning,
    dynamic item,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WordDeepDiveSheet(
        wordData: wordData,
        word: word,
        article: article,
        meaning: meaning,
        example: example,
        exampleMeaning: exampleMeaning,
        item: item,
      ),
    );
  }


  static String? _value(Object? input) {
    if (input == null) return null;
    final text = input.toString().trim();
    return text.isEmpty ? null : text;
  }

  static Map<String, dynamic> _fields(Map<String, dynamic> data) {
    final resolved = <String, dynamic>{};
    final serialized = data['fields_json'];
    if (serialized is String && serialized.isNotEmpty) {
      try {
        final decoded = jsonDecode(serialized);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            if (entry.value != null) {
              resolved[entry.key.toString()] = entry.value;
            }
          }
        }
      } on FormatException {
        // A corrupt optional JSON field never prevents rendering the lemma.
      }
    }
    final supplied = data['fields'];
    if (supplied is Map) {
      for (final entry in supplied.entries) {
        if (entry.value != null) {
          resolved[entry.key.toString()] = entry.value;
        }
      }
    }
    return resolved;
  }

  static String? _first(Iterable<Object?> options) {
    for (final option in options) {
      final candidate = _value(option);
      if (candidate != null) return candidate;
    }
    return null;
  }

  /// Convert optional lexicon examples to the existing widget contract.
  /// Missing or malformed translations never produce a blank example card.
  static String? examplesJsonFor(Map<String, dynamic> data) {
    final fields = _fields(data);
    final raw = fields['examples'] ?? data['examples'];
    Object? decoded = raw;
    if (raw is String) {
      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        decoded = null;
      }
    }
    final valid = <Map<String, String>>[];
    if (decoded is List) {
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final source = _first(<Object?>[
          entry['sentence'], entry['text'], entry['example'],
        ]);
        final target = _first(<Object?>[
          entry['translation'], entry['translation_ar'],
          entry['meaning_ar'],
        ]);
        if (source != null && target != null) {
          valid.add(<String, String>{
            'sentence': source,
            'translation': target,
          });
        }
      }
    }
    if (valid.isEmpty) {
      final source = _first(<Object?>[
        data['sentence'], data['example'], fields['sentence'],
        fields['example'],
      ]);
      final target = _first(<Object?>[
        data['exampleMeaning'], data['example_translation'],
        fields['example_translation_ar'], fields['sentence_translation_ar'],
        fields['exampleMeaning'],
      ]);
      if (source != null && target != null) {
        valid.add(<String, String>{
          'sentence': source,
          'translation': target,
        });
      }
    }
    return valid.isEmpty ? null : jsonEncode(valid);
  }

  @override
  Widget build(BuildContext context) {
    final data = wordData ??
        (item is Map ? (item as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        ) : <String, dynamic>{});
    final fields = _fields(data);
    final displayWord = _first(<Object?>[
      word, data['lemma'], data['word'], data['surface'],
      data['display_text'],
    ]) ?? 'مفردة';
    final displayArticle = _first(<Object?>[
      article, data['article'], fields['article'],
    ]);
    final displayMeaning = _first(<Object?>[
      meaning, data['translation_ar'], data['meaning'],
      fields['translation_ar'], fields['translation'],
    ]) ?? 'المعنى غير متوفر';
    final displayExample = _first(<Object?>[
      example, data['sentence'], fields['sentence'],
    ]);
    final displayExampleMeaning = _first(<Object?>[
      exampleMeaning, data['exampleMeaning'], fields['example_translation_ar'],
    ]);
    final displayData = <String, dynamic>{
      ...data,
      if (displayExample != null) 'sentence': displayExample,
      if (displayExampleMeaning != null)
        'exampleMeaning': displayExampleMeaning,
    };
    final lang = _first(<Object?>[
      data['language_code'], fields['language_code'],
    ]) ?? 'de';
    final pos = _first(<Object?>[
      data['part_of_speech'], fields['part_of_speech'],
    ]) ?? '';
    final ipa = _first(<Object?>[
      fields['ipa'], fields['phonetic_ipa'], fields['pronunciation_ipa'],
      data['ipa'],
    ]);
    final headwordId = _first(<Object?>[
      data['id'], data['lexeme_id'],
    ]) ?? '';
    final classifier = _first(<Object?>[
      fields['classifier'], fields['measure_word'], fields['noun_class'],
      data['classifier'],
    ]) ?? '';
    final reading = _first(<Object?>[
      fields['classifier_reading'], fields['measure_word_reading'],
    ]) ?? '';
    final explanation = _first(<Object?>[
      fields['classifier_explanation'], fields['measure_word_explanation'],
    ]) ?? '';
    final examples = examplesJsonFor(displayData);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (displayArticle != null || pos.isNotEmpty || classifier.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  if (displayArticle != null)
                    ArticleBadge(article: displayArticle),
                  if (pos.isNotEmpty)
                    Chip(label: Text(pos)),
                  if (classifier.isNotEmpty)
                    NounClassifierView(
                    noun: displayWord,
                    languageCode: lang,
                    partOfSpeech: pos,
                    classifier: classifier,
                    reading: reading,
                    explanation: explanation,
                  ),
                ],
              ),
            BidiLexiconView(
              sourceWord: displayWord,
              sourceLanguageCode: lang,
              targetExplanation: displayMeaning,
              sourceStyle: AppTypography.h1,
              explanationStyle: AppTypography.bodyMedium,
              phonetic: hasPhoneticData(ipa)
                  ? PhoneticIpaView(ipa: ipa)
                  : null,
            ),
            if (examples != null) ...<Widget>[
              const SizedBox(height: 12),
              ExampleSentencesView(
                examplesJson: examples,
                keyword: displayWord,
                sourceLanguageCode: lang,
              ),
            ],
            // No surrounding spacing when the optional idioms panel
            // collapses because its table or records are absent.
            if (headwordId.isNotEmpty)
              IdiomsView(
                headwordId: headwordId,
                languageCode: lang,
              ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }
}
