import 'dart:math' as math;

class LexicalDiversityReport {
  final int totalTokens;
  final int uniqueTypes;
  final double rawTtr;
  final double guiraudIndex;
  final double advancedVocabRatio;
  final List<String> overusedTokens;
  final String fluencyFeedback;

  const LexicalDiversityReport({
    required this.totalTokens,
    required this.uniqueTypes,
    required this.rawTtr,
    required this.guiraudIndex,
    required this.advancedVocabRatio,
    required this.overusedTokens,
    required this.fluencyFeedback,
  });

  Map<String, dynamic> toJson() => {
    'totalTokens': totalTokens,
    'uniqueTypes': uniqueTypes,
    'rawTtr': rawTtr,
    'guiraudIndex': guiraudIndex,
    'advancedVocabRatio': advancedVocabRatio,
    'overusedTokens': overusedTokens,
    'fluencyFeedback': fluencyFeedback,
  };
}

class LexicalDiversityAnalyticsEngine {
  static const Set<String> _advancedMarkers = {
    'allerdings', 'außerdem', 'beziehungsweise', 'dennoch', 'deshalb',
    'infolgedessen', 'mittlerweile', 'tatsächlich', 'überraschenderweise',
    'voraussetzung', 'hervorragend', 'ausgezeichnet', 'erfahrung', 'herausforderung'
  };

  const LexicalDiversityAnalyticsEngine();

  /// Analyzes learner turns across a conversation and outputs a comprehensive lexical report.
  LexicalDiversityReport analyzeTranscript(List<String> userTurns) {
    if (userTurns.isEmpty) {
      return const LexicalDiversityReport(
        totalTokens: 0,
        uniqueTypes: 0,
        rawTtr: 0.0,
        guiraudIndex: 0.0,
        advancedVocabRatio: 0.0,
        overusedTokens: [],
        fluencyFeedback: 'Keine Äußerungen vorhanden.',
      );
    }

    final List<String> tokens = [];
    final Map<String, int> frequencies = {};
    int advancedCount = 0;

    for (final turn in userTurns) {
      final words = turn
          .toLowerCase()
          .replaceAll(RegExp(r'[^\wäöüÄÖÜß\s]'), '')
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty);

      for (final word in words) {
        tokens.add(word);
        frequencies[word] = (frequencies[word] ?? 0) + 1;
        if (_advancedMarkers.contains(word)) {
          advancedCount++;
        }
      }
    }

    final int total = tokens.length;
    final int unique = frequencies.keys.length;

    if (total == 0) {
      return const LexicalDiversityReport(
        totalTokens: 0,
        uniqueTypes: 0,
        rawTtr: 0.0,
        guiraudIndex: 0.0,
        advancedVocabRatio: 0.0,
        overusedTokens: [],
        fluencyFeedback: 'Keine Wörter erfasst.',
      );
    }

    final double ttr = unique / total;
    final double guiraud = unique / math.sqrt(total);
    final double advRatio = advancedCount / total;

    // Detect words accounting for more than 8% of entire dialogue
    final overused = <String>[];
    frequencies.forEach((word, count) {
      if (word.length > 3 && (count / total) > 0.08 && count >= 3) {
        overused.add(word);
      }
    });

    String feedback;
    if (guiraud >= 5.5) {
      feedback = 'Hervorragender Wortschatz! Sie nutzen eine breite Palette an Begriffen und Ausdrücken.';
    } else if (guiraud >= 4.0) {
      feedback = 'Guter Sprachfluss mit solider lexikalischer Vielfalt. Versuchen Sie, häufige Wörter noch stärker zu variieren.';
    } else {
      feedback = 'Gute Basis. Nutzen Sie Synonyme und Umschreibungen, um Wiederholungen zu reduzieren.';
    }

    return LexicalDiversityReport(
      totalTokens: total,
      uniqueTypes: unique,
      rawTtr: double.parse(ttr.toStringAsFixed(3)),
      guiraudIndex: double.parse(guiraud.toStringAsFixed(2)),
      advancedVocabRatio: double.parse(advRatio.toStringAsFixed(3)),
      overusedTokens: overused,
      fluencyFeedback: feedback,
    );
  }
}
