import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/language_pack_manager.dart';
import '../services/tts_service.dart';
import '../services/hybrid_audio_service.dart';

/// A valid, translated usage example for a vocabulary entry.
class ExampleSentence {
  const ExampleSentence({
    required this.sentence,
    required this.translation,
  });

  final String sentence;
  final String translation;

  /// Invalid JSON, malformed entries, and entries with no sentence or
  /// translation produce no visible example rather than a broken card.
  static List<ExampleSentence> parseJson(String? examplesJson) {
    if (examplesJson == null || examplesJson.trim().isEmpty) {
      return const <ExampleSentence>[];
    }

    try {
      final decoded = jsonDecode(examplesJson);
      if (decoded is! List) return const <ExampleSentence>[];

      final examples = <ExampleSentence>[];
      for (final value in decoded) {
        if (value is! Map) continue;

        final rawSentence = value['sentence'];
        final rawTranslation = value['translation'];
        if (rawSentence is! String || rawTranslation is! String) continue;

        final sentence = rawSentence.trim();
        final translation = rawTranslation.trim();
        if (sentence.isEmpty || translation.isEmpty) continue;

        examples.add(ExampleSentence(
          sentence: sentence,
          translation: translation,
        ));
      }
      return List<ExampleSentence>.unmodifiable(examples);
    } on FormatException {
      return const <ExampleSentence>[];
    }
  }
}

/// Displays offline usage examples without reserving space for empty entries.
///
/// [examplesJson] is a JSON array of objects containing `sentence` and
/// `translation`. Playback uses the device's TTS engine via [TtsService].
/// A service may be supplied by the parent to share TTS state across screens.
class ExampleSentencesView extends StatefulWidget {
  const ExampleSentencesView({
    super.key,
    required this.examplesJson,
    required this.keyword,
    this.sourceLanguageCode = 'de',
    this.translationLanguageCode = 'ar',
    this.ttsService,
  });

  final String? examplesJson;
  final String keyword;
  final String sourceLanguageCode;
  final String translationLanguageCode;
  final TtsService? ttsService;

  @override
  State<ExampleSentencesView> createState() => _ExampleSentencesViewState();
}

class _ExampleSentencesViewState extends State<ExampleSentencesView> {
  TtsService? _ownedTts;

  Future<void> _speak(String sentence) async {
    final tts = widget.ttsService ?? (_ownedTts ??= TtsService());
    try {
      final audio = HybridAudioService(
        ttsService: tts,
        // Injected TTS instances can be test doubles; the TtsService.speak
        // implementation independently checks installed voices in production.
        voiceProbe: widget.ttsService != null ? (_) async => true : null,
      );
      await audio.play(
        text: sentence,
        languageCode: widget.sourceLanguageCode,
        context: mounted ? context : null,
      );
    } catch (error) {
      debugPrint('Example sentence TTS failed: $error');
    }
  }

  @override
  void dispose() {
    final ownedTts = _ownedTts;
    if (ownedTts != null) unawaited(ownedTts.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final examples = ExampleSentence.parseJson(widget.examplesJson);
    if (examples.isEmpty) return const SizedBox.shrink();

    final translationDirection =
        LanguagePackManager.isRtlLanguage(widget.translationLanguageCode)
            ? TextDirection.rtl
            : TextDirection.ltr;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final example in examples)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          children: _highlightedSpans(
                            sentence: example.sentence,
                            keyword: widget.keyword,
                            accent: theme.colorScheme.primary,
                          ),
                        ),
                        style: theme.textTheme.bodyLarge,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        example.translation,
                        textDirection: translationDirection,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_outlined),
                  tooltip: 'Speak example sentence',
                  onPressed: () => unawaited(_speak(example.sentence)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static List<InlineSpan> _highlightedSpans({
    required String sentence,
    required String keyword,
    required Color accent,
  }) {
    final target = keyword.trim();
    if (target.isEmpty) return <InlineSpan>[TextSpan(text: sentence)];

    final pattern = RegExp(RegExp.escape(target), caseSensitive: false);
    final spans = <InlineSpan>[];
    var previousEnd = 0;

    for (final match in pattern.allMatches(sentence)) {
      if (match.start > previousEnd) {
        spans.add(TextSpan(text: sentence.substring(previousEnd, match.start)));
      }
      spans.add(TextSpan(
        text: sentence.substring(match.start, match.end),
        style: TextStyle(color: accent, fontWeight: FontWeight.bold),
      ));
      previousEnd = match.end;
    }

    if (previousEnd < sentence.length) {
      spans.add(TextSpan(text: sentence.substring(previousEnd)));
    }
    return spans;
  }
}
