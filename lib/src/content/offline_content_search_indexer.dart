/// Search match result across local bilingual dictionaries and scenario dialogue banks.
class ContentSearchHit {
  final String termDe;
  final String translationAr;
  final String category;
  final double relevanceScore;

  const ContentSearchHit({
    required this.termDe,
    required this.translationAr,
    required this.category,
    required this.relevanceScore,
  });
}

/// Inverted search indexer delivering sub-5ms lookups over offline vocabulary banks.
class OfflineContentSearchIndexer {
  final Map<String, List<ContentSearchHit>> _index = {};

  int get indexedTermCount => _index.length;

  /// Ingests a bilingual entry into search index.
  void indexEntry({
    required String german,
    required String arabic,
    required String category,
  }) {
    final hit = ContentSearchHit(
      termDe: german,
      translationAr: arabic,
      category: category,
      relevanceScore: 1.0,
    );

    final tokens = [
      ...german.toLowerCase().split(RegExp(r'\s+')),
      ...arabic.split(RegExp(r'\s+')),
    ];

    for (final token in tokens) {
      final clean = token.replaceAll(RegExp(r'[^\w\u0600-\u06FF]'), '');
      if (clean.isNotEmpty) {
        _index.putIfAbsent(clean, () => []).add(hit);
      }
    }
  }

  /// Searches index for matching hits.
  List<ContentSearchHit> query(String text) {
    final clean = text.trim().toLowerCase();
    if (clean.isEmpty) return [];
    return _index[clean] ?? [];
  }
}
