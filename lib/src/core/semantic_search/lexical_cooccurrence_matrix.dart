/// Co-occurrence statistics between two words in a sliding window.
class CooccurrencePair {
  final String wordA;
  final String wordB;
  final int count;
  final double associationStrength;

  const CooccurrencePair({
    required this.wordA,
    required this.wordB,
    required this.count,
    required this.associationStrength,
  });
}

/// Dynamic word co-occurrence matrix for thematic clustering and topical coherence evaluation.
class LexicalCooccurrenceMatrix {
  final int windowRadius;
  final Map<String, Map<String, int>> _matrix = {};

  LexicalCooccurrenceMatrix({this.windowRadius = 3});

  int get uniqueWordCount => _matrix.length;

  /// Ingests a text passage and updates the symmetric co-occurrence matrix.
  void ingestPassage(String text) {
    final tokens = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    for (int i = 0; i < tokens.length; i++) {
      final target = tokens[i];
      final start = (i - windowRadius).clamp(0, tokens.length);
      final end = (i + windowRadius + 1).clamp(0, tokens.length);

      final row = _matrix.putIfAbsent(target, () => {});
      for (int j = start; j < end; j++) {
        if (i != j) {
          final contextWord = tokens[j];
          row[contextWord] = (row[contextWord] ?? 0) + 1;
        }
      }
    }
  }

  /// Retrieves top co-occurring neighbors for a target word.
  List<CooccurrencePair> getTopAssociates(String word, {int topK = 5}) {
    final row = _matrix[word.trim().toLowerCase()];
    if (row == null || row.isEmpty) return [];

    int maxCount = 0;
    for (final c in row.values) {
      if (c > maxCount) maxCount = c;
    }

    final pairs = row.entries.map((e) {
      final strength = maxCount > 0 ? (e.value / maxCount) : 1.0;
      return CooccurrencePair(
        wordA: word,
        wordB: e.key,
        count: e.value,
        associationStrength: double.parse(strength.toStringAsFixed(2)),
      );
    }).toList();

    pairs.sort((a, b) => b.count.compareTo(a.count));
    return pairs.take(topK).toList();
  }
}
