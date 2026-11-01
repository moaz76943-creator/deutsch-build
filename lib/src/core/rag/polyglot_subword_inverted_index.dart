import 'dart:math' as math;

class SubwordPosting {
  final String docId;
  final int frequency;

  const SubwordPosting({required this.docId, required this.frequency});
}

class SubwordSearchHit {
  final String docId;
  final double score;
  final int matchedNgramsCount;

  const SubwordSearchHit({
    required this.docId,
    required this.score,
    required this.matchedNgramsCount,
  });
}

/// Sovereign on-device character n-gram subword inverted index.
/// Excels at handling morphologically rich and agglutinative languages
/// (Turkish, Swahili, Uzbek, Indonesian, Arabic, Finnish, German compound words)
/// without requiring heavyweight external morphological analyzers.
class PolyglotSubwordInvertedIndex {
  final int minNgram;
  final int maxNgram;
  final Map<String, List<SubwordPosting>> _index = {};
  final Map<String, int> _docLengths = {}; // docId -> total ngrams count
  final Map<String, String> _docTexts = {};

  PolyglotSubwordInvertedIndex({
    this.minNgram = 3,
    this.maxNgram = 5,
  });

  int get uniqueNgramCount => _index.length;
  int get documentCount => _docLengths.length;

  /// Extracts character n-grams from normalized text with word boundary markers.
  List<String> extractNgrams(String text) {
    final clean = text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // Arabic diacritics
        .replaceAll(RegExp(r'\s+'), ' ');

    if (clean.isEmpty) return const [];

    final words = clean.split(' ');
    final ngrams = <String>[];

    for (final word in words) {
      if (word.isEmpty) continue;
      final bounded = '^$word\$';
      for (int n = minNgram; n <= maxNgram; n++) {
        if (bounded.length < n) continue;
        for (int i = 0; i <= bounded.length - n; i++) {
          ngrams.add(bounded.substring(i, i + n));
        }
      }
    }

    return ngrams;
  }

  /// Inserts a document into the subword inverted index.
  void addDocument(String docId, String text) {
    if (_docLengths.containsKey(docId)) {
      removeDocument(docId);
    }

    final ngrams = extractNgrams(text);
    _docLengths[docId] = ngrams.length;
    _docTexts[docId] = text;

    final tfMap = <String, int>{};
    for (final ng in ngrams) {
      tfMap[ng] = (tfMap[ng] ?? 0) + 1;
    }

    for (final entry in tfMap.entries) {
      _index.putIfAbsent(entry.key, () => []).add(SubwordPosting(
            docId: docId,
            frequency: entry.value,
          ));
    }
  }

  void removeDocument(String docId) {
    _docLengths.remove(docId);
    _docTexts.remove(docId);
    _index.forEach((_, postings) {
      postings.removeWhere((p) => p.docId == docId);
    });
    _index.removeWhere((_, postings) => postings.isEmpty);
  }

  /// Searches the subword index using Dice/Jaccard overlap coefficient scoring.
  List<SubwordSearchHit> search(String query, {int topK = 10}) {
    final queryNgrams = extractNgrams(query);
    if (queryNgrams.isEmpty || _docLengths.isEmpty) return const [];

    final qNgramSet = queryNgrams.toSet();
    final docMatches = <String, int>{};
    final docMatchedUniqueNgrams = <String, int>{};

    for (final ng in qNgramSet) {
      final postings = _index[ng];
      if (postings != null) {
        for (final p in postings) {
          docMatches[p.docId] = (docMatches[p.docId] ?? 0) + p.frequency;
          docMatchedUniqueNgrams[p.docId] = (docMatchedUniqueNgrams[p.docId] ?? 0) + 1;
        }
      }
    }

    final hits = <SubwordSearchHit>[];
    final qLen = queryNgrams.length;

    for (final entry in docMatches.entries) {
      final docId = entry.key;
      final docLen = _docLengths[docId] ?? 1;
      final matchCount = entry.value;

      // Sørensen–Dice coefficient over sub-word sequences: 2 * |Q ∩ D| / (|Q| + |D|)
      final diceScore = (2.0 * matchCount) / (qLen + docLen);

      hits.add(SubwordSearchHit(
        docId: docId,
        score: diceScore,
        matchedNgramsCount: docMatchedUniqueNgrams[docId] ?? 0,
      ));
    }

    hits.sort((a, b) => b.score.compareTo(a.score));

    if (topK > 0 && hits.length > topK) {
      return hits.sublist(0, topK);
    }
    return hits;
  }
}
