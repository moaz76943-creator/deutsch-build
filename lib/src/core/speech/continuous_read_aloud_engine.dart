import 'dart:math';

/// State of a word token during real-time continuous reading.
enum ReadAloudTokenStatus {
  pending,
  current,
  correct,
  mispronounced,
  skipped,
}

/// Token tracked along the continuous reading timeline.
class ReadAloudToken {
  final String text;
  final int index;
  ReadAloudTokenStatus status;

  ReadAloudToken({
    required this.text,
    required this.index,
    this.status = ReadAloudTokenStatus.pending,
  });
}

/// Diagnostic summary generated at the conclusion of paragraph reading.
class ContinuousReadAloudReport {
  final int totalWords;
  final int correctWordsCount;
  final int mispronouncedCount;
  final int skippedCount;
  final double accuracyPercentage;

  const ContinuousReadAloudReport({
    required this.totalWords,
    required this.correctWordsCount,
    required this.mispronouncedCount,
    required this.skippedCount,
    required this.accuracyPercentage,
  });
}

/// Manages continuous non-intrusive read-aloud tracking across full paragraphs.
class ContinuousReadAloudEngine {
  final List<ReadAloudToken> _tokens = [];
  int _currentIndex = 0;

  ContinuousReadAloudEngine();

  List<ReadAloudToken> get tokens => List.unmodifiable(_tokens);
  int get currentIndex => _currentIndex;
  bool get isCompleted => _currentIndex >= _tokens.length;

  /// Loads target paragraph and tokenizes words.
  void loadParagraph(String paragraphText) {
    _tokens.clear();
    _currentIndex = 0;
    final words = paragraphText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    for (int i = 0; i < words.length; i++) {
      _tokens.add(ReadAloudToken(text: words[i], index: i));
    }

    if (_tokens.isNotEmpty) {
      _tokens.first.status = ReadAloudTokenStatus.current;
    }
  }

  /// Processes spoken word hypothesis, marking progress non-intrusively.
  void onSpokenWordObserved(String spokenWord, {required bool isAccurate}) {
    if (isCompleted) return;

    final token = _tokens[_currentIndex];
    token.status = isAccurate
        ? ReadAloudTokenStatus.correct
        : ReadAloudTokenStatus.mispronounced;

    _currentIndex++;

    if (_currentIndex < _tokens.length) {
      _tokens[_currentIndex].status = ReadAloudTokenStatus.current;
    }
  }

  /// Generates final reading diagnostic scorecard.
  ContinuousReadAloudReport finalizeReport() {
    int correct = 0;
    int mispronounced = 0;
    int skipped = 0;

    for (final t in _tokens) {
      switch (t.status) {
        case ReadAloudTokenStatus.correct:
          correct++;
          break;
        case ReadAloudTokenStatus.mispronounced:
          mispronounced++;
          break;
        case ReadAloudTokenStatus.skipped:
        case ReadAloudTokenStatus.pending:
        case ReadAloudTokenStatus.current:
          skipped++;
          break;
      }
    }

    final total = _tokens.length;
    final double acc = total > 0 ? (correct / total * 100.0) : 0.0;

    return ContinuousReadAloudReport(
      totalWords: total,
      correctWordsCount: correct,
      mispronouncedCount: mispronounced,
      skippedCount: skipped,
      accuracyPercentage: double.parse(acc.toStringAsFixed(1)),
    );
  }
}
