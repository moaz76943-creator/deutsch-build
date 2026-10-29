import 'dart:convert';

import 'package:flutter/material.dart';

import 'bidi_lexicon_view.dart';
import 'example_sentences_view.dart';
import 'idioms_view.dart';
import 'noun_classifier_view.dart';
import 'phonetic_ipa_view.dart';

/// Shared presentation for a lexicon row in the active dictionary and cards.
/// Accepts the original lexicon fields without changing the database schema.
class LexiconRichDetails extends StatelessWidget {
  const LexiconRichDetails({
    super.key,
    required this.entry,
    this.languageCode = 'de',
    this.showMeaning = true,
    this.showExamples = true,
    this.showIdioms = true,
  });

  final Map<String, dynamic> entry;
  final String languageCode;
  final bool showMeaning;
  final bool showExamples;
  final bool showIdioms;

  static Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return _map(decoded);
      } on FormatException {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  static String _text(Object? value) {
    if (value == null || value is Map || value is List) return '';
    return value.toString().trim();
  }

  static String _get(
    Map<String, dynamic> entry,
    Map<String, dynamic> fields,
    Map<String, dynamic> canonical,
    List<String> keys,
  ) {
    for (final source in <Map<String, dynamic>>[entry, fields, canonical]) {
      for (final key in keys) {
        final text = _text(source[key]);
        if (text.isNotEmpty) return text;
      }
    }
    return '';
  }

  /// Read an installed-pack surface form without reconstructing a word.
  static String headword(Map<String, dynamic> entry) {
    final fields = _fields(entry);
    return _get(entry, fields, _map(fields['canonical']),
        <String>['word', 'lemma', 'surface', 'display_text']);
  }

  static Map<String, dynamic> _fields(Map<String, dynamic> entry) {
    final parsed = _map(entry['fields_json']);
    return <String, dynamic>{
      ...parsed,
      ..._map(entry['fields']),
    };
  }

  static String? _examples(
    Map<String, dynamic> entry,
    Map<String, dynamic> fields,
    Map<String, dynamic> canonical,
  ) {
    Object? raw;
    for (final source in <Map<String, dynamic>>[entry, fields, canonical]) {
      raw ??= source['examples_json'] ?? source['examples'] ??
          source['example_sentences'];
    }
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } on FormatException {
        raw = null;
      }
    }

    final normalized = <Map<String, String>>[];
    if (raw is List) {
      for (final element in raw) {
        final example = _map(element);
        final sentence = _get(example, const <String, dynamic>{},
            const <String, dynamic>{}, <String>['sentence', 'text']);
        final translation = _get(example, const <String, dynamic>{},
            const <String, dynamic>{},
            <String>['translation', 'translation_ar', 'sentence_translation_ar']);
        if (sentence.isNotEmpty && translation.isNotEmpty) {
          normalized.add(<String, String>{
            'sentence': sentence,
            'translation': translation,
          });
        }
      }
    }
    if (normalized.isEmpty) {
      final sentence = _get(entry, fields, canonical,
          <String>['sentence', 'example']);
      final translation = _get(entry, fields, canonical, <String>[
        'sentence_translation_ar',
        'example_translation_ar',
        'exampleMeaning',
      ]);
      if (sentence.isNotEmpty && translation.isNotEmpty) {
        normalized.add(<String, String>{
          'sentence': sentence,
          'translation': translation,
        });
      }
    }
    return normalized.isEmpty ? null : jsonEncode(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final fields = _fields(entry);
    final canonical = _map(fields['canonical']);
    final word = headword(entry);
    final meaning = _get(entry, fields, canonical,
        <String>['meaning', 'translation_ar', 'translation', 'definition_ar']);
    final article = _get(entry, fields, canonical, <String>['article']);
    final partOfSpeech = _get(
        entry, fields, canonical, <String>['part_of_speech', 'pos']);
    final phonetics = _map(fields['phonetics']);
    final ipa = _get(entry, fields, canonical,
        <String>['ipa', 'ipa_transcription', 'phonetic_ipa']);
    final transcription = ipa.isNotEmpty
        ? ipa
        : _get(phonetics, const <String, dynamic>{},
            const <String, dynamic>{}, <String>['ipa']);
    final classifier = _get(entry, fields, canonical, <String>[
      'classifier',
      'measure_word',
      'noun_class',
      'noun_classifier',
    ]);
    final classifierReading = _get(entry, fields, canonical,
        <String>['classifier_reading', 'pinyin', 'reading']);
    final classifierExplanation = _get(entry, fields, canonical,
        <String>['classifier_explanation', 'noun_class_explanation']);
    final id = _get(entry, fields, canonical,
        <String>['id', 'lexeme_id', 'headword_id']);
    final code = _get(entry, fields, canonical,
        <String>['language_code']);
    final sourceLanguage = code.isNotEmpty ? code : languageCode;
    final examplesJson = showExamples ? _examples(entry, fields, canonical) : null;
    final nounMetadata = classifier.isNotEmpty &&
        partOfSpeech.isNotEmpty &&
        word.isNotEmpty;

    if (word.isEmpty &&
        (!showMeaning || meaning.isEmpty) &&
        !hasPhoneticData(transcription) &&
        !nounMetadata &&
        examplesJson == null &&
        (!showIdioms || id.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (article.isNotEmpty || partOfSpeech.isNotEmpty || nounMetadata)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                if (article.isNotEmpty)
                  Chip(label: Text(article)),
                if (partOfSpeech.isNotEmpty)
                  Chip(label: Text(partOfSpeech)),
                if (nounMetadata)
                  NounClassifierView(
                    noun: word,
                    languageCode: sourceLanguage,
                    partOfSpeech: partOfSpeech,
                    classifier: classifier,
                    reading: classifierReading,
                    explanation: classifierExplanation,
                  ),
              ],
            ),
          ),
        if (word.isNotEmpty || (showMeaning && meaning.isNotEmpty))
          BidiLexiconView(
            sourceWord: word,
            sourceLanguageCode: sourceLanguage,
            targetExplanation: showMeaning ? meaning : '',
            phonetic: hasPhoneticData(transcription)
                ? PhoneticIpaView(ipa: transcription)
                : null,
          ),
        if (examplesJson != null)
          ExampleSentencesView(
            examplesJson: examplesJson,
            keyword: word,
            sourceLanguageCode: sourceLanguage,
          ),
        if (showIdioms && id.isNotEmpty)
          IdiomsView(
            headwordId: id,
            languageCode: sourceLanguage,
          ),
      ],
    );
  }
}
