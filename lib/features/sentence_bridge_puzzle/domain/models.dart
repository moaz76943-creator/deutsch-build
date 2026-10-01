class PuzzleItem {
  final String id;
  final String conceptId;
  final String germanSentence;
  final String arabicSentence;

  const PuzzleItem({
    required this.id,
    required this.conceptId,
    required this.germanSentence,
    required this.arabicSentence,
  });

  List<String> get scrambledWords {
    final words = germanSentence
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\wäöüßÄÖÜ]'), ''))
        .where((w) => w.isNotEmpty)
        .toList();
    words.shuffle();
    return words;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conceptId': conceptId,
      'germanSentence': germanSentence,
      'arabicSentence': arabicSentence,
    };
  }

  factory PuzzleItem.fromMap(Map<String, dynamic> map) {
    return PuzzleItem(
      id: map['id'] as String,
      conceptId: map['conceptId'] as String,
      germanSentence: map['germanSentence'] as String,
      arabicSentence: map['arabicSentence'] as String,
    );
  }
}

class PuzzleAttempt {
  final String id;
  final String puzzleId;
  final bool isCorrect;
  final DateTime timestamp;
  final int timeTakenMs;

  const PuzzleAttempt({
    required this.id,
    required this.puzzleId,
    required this.isCorrect,
    required this.timestamp,
    required this.timeTakenMs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'puzzleId': puzzleId,
      'isCorrect': isCorrect ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'timeTakenMs': timeTakenMs,
    };
  }

  factory PuzzleAttempt.fromMap(Map<String, dynamic> map) {
    return PuzzleAttempt(
      id: map['id'] as String,
      puzzleId: map['puzzleId'] as String,
      isCorrect: (map['isCorrect'] as int) == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      timeTakenMs: map['timeTakenMs'] as int,
    );
  }
}
