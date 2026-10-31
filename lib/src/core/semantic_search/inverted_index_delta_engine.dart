import 'dart:math' as math;

/// Single posting entry linking a term to a document with term frequency.
class Posting {
  final String docId;
  final int termFrequency;

  const Posting({required this.docId, required this.termFrequency});
}

/// Offline inverted index supporting live append-only delta updates in sub-millisecond time.
class InvertedIndexDeltaEngine {
  final Map<String, List<Posting>> _index = {};
  final Map<String, int> _docLengths = {};

  int get totalDocuments => _docLengths.length;
  int get vocabularySize => _index.length;

  /// Tokenizes text into lowercase normalized terms.
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// Appends a new document or user note incrementally into the index.
  void indexDocument({required String docId, required String content}) {
    final tokens = _tokenize(content);
    _docLengths[docId] = tokens.length;

    final tfMap = <String, int>{};
    for (final token in tokens) {
      tfMap[token] = (tfMap[token] ?? 0) + 1;
    }

    for (final entry in tfMap.entries) {
      final term = entry.key;
      final tf = entry.value;
      final postings = _index.putIfAbsent(term, () => []);
      postings.removeWhere((p) => p.docId == docId); // Overwrite if re-indexing
      postings.add(Posting(docId: docId, termFrequency: tf));
    }
  }

  /// Searches the inverted index for documents matching query terms.
  Map<String, double> search(String query) {
    final queryTokens = _tokenize(query);
    if (queryTokens.isEmpty || totalDocuments == 0) return {};

    final scores = <String, double>{};
    final avgDocLen = _docLengths.values.reduce((a, b) => a + b) / totalDocuments;

    for (final term in queryTokens) {
      final postings = _index[term];
      if (postings == null) continue;

      // Inverse Document Frequency (IDF)
      final df = postings.length;
      final idf = math.log(1.0 + (totalDocuments - df + 0.5) / (df + 0.5));

      for (final p in postings) {
        final docLen = _docLengths[p.docId] ?? avgDocLen;
        final tf = p.termFrequency;
        final normTf = (tf * 2.2) / (tf + 1.2 * (0.25 + 0.75 * (docLen / avgDocLen)));
        final termScore = idf * normTf;
        scores[p.docId] = (scores[p.docId] ?? 0.0) + termScore;
      }
    }

    return scores;
  }
}
