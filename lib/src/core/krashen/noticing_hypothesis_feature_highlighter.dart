enum TypographicalEnhancementMode {
  subtleBold, // **morpheme**
  colorAccentSpan, // <span class="accent-grammar">morpheme</span>
  underlinedTarget, // <u>morpheme</u>
  bracketedRoleTag, // morpheme [ACC]
}

class HighlightSpan {
  final int charStart;
  final int charEnd;
  final String targetSegment;
  final String grammaticalCategory;
  final TypographicalEnhancementMode mode;

  const HighlightSpan({
    required this.charStart,
    required this.charEnd,
    required this.targetSegment,
    required this.grammaticalCategory,
    required this.mode,
  });
}

class EnhancedInputText {
  final String originalText;
  final String renderedMarkup;
  final List<HighlightSpan> spans;
  final String targetGrammarRule;

  const EnhancedInputText({
    required this.originalText,
    required this.renderedMarkup,
    required this.spans,
    required this.targetGrammarRule,
  });
}

/// Sovereign on-device Noticing Hypothesis Feature Highlighter.
/// Implements Richard Schmidt's Noticing Hypothesis ("input does not become intake
/// unless it is noticed") via gentle, non-intrusive typographical enhancement.
class NoticingHypothesisFeatureHighlighter {
  const NoticingHypothesisFeatureHighlighter();

  /// Highlights target morphemes/tokens in a sentence to focus the learner's attention.
  EnhancedInputText highlightTargetFeatures({
    required String sentence,
    required List<String> targetMorphemes,
    required String grammarRuleTitle,
    TypographicalEnhancementMode mode = TypographicalEnhancementMode.subtleBold,
  }) {
    if (sentence.trim().isEmpty || targetMorphemes.isEmpty) {
      return EnhancedInputText(
        originalText: sentence,
        renderedMarkup: sentence,
        spans: const [],
        targetGrammarRule: grammarRuleTitle,
      );
    }

    final spans = <HighlightSpan>[];
    String markup = sentence;

    // Sort morphemes by descending length to avoid partial sub-token collisions
    final sortedMorphemes = List<String>.from(targetMorphemes)
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final morpheme in sortedMorphemes) {
      if (morpheme.isEmpty) continue;
      int searchStart = 0;

      while (searchStart < sentence.length) {
        final idx = sentence.indexOf(morpheme, searchStart);
        if (idx == -1) break;

        spans.add(HighlightSpan(
          charStart: idx,
          charEnd: idx + morpheme.length,
          targetSegment: morpheme,
          grammaticalCategory: grammarRuleTitle,
          mode: mode,
        ));

        searchStart = idx + morpheme.length;
      }
    }

    // Sort spans by start offset
    spans.sort((a, b) => a.charStart.compareTo(b.charStart));

    // Build markup from clean spans
    if (spans.isNotEmpty) {
      final buffer = StringBuffer();
      int lastIndex = 0;

      for (final span in spans) {
        if (span.charStart < lastIndex) continue; // Skip overlaps
        buffer.write(sentence.substring(lastIndex, span.charStart));

        switch (span.mode) {
          case TypographicalEnhancementMode.subtleBold:
            buffer.write('**${span.targetSegment}**');
            break;
          case TypographicalEnhancementMode.colorAccentSpan:
            buffer.write('<span class="grammar-accent">${span.targetSegment}</span>');
            break;
          case TypographicalEnhancementMode.underlinedTarget:
            buffer.write('<u>${span.targetSegment}</u>');
            break;
          case TypographicalEnhancementMode.bracketedRoleTag:
            buffer.write('${span.targetSegment} [${span.grammaticalCategory}]');
            break;
        }

        lastIndex = span.charEnd;
      }

      if (lastIndex < sentence.length) {
        buffer.write(sentence.substring(lastIndex));
      }
      markup = buffer.toString();
    }

    return EnhancedInputText(
      originalText: sentence,
      renderedMarkup: markup,
      spans: spans,
      targetGrammarRule: grammarRuleTitle,
    );
  }
}
