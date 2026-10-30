import 'dart:collection';

/// A memory page holding quantized vectors.
class VectorPage {
  final int pageId;
  final Map<String, List<int>> vectorData; // vectorId -> quantized bytes
  bool isDirty;

  VectorPage({
    required this.pageId,
    required this.vectorData,
    this.isDirty = false,
  });

  int get count => vectorData.length;
}

/// LRU Memory Pager enforcing strict RAM limits on mobile vector stores.
class VectorLruCachePager {
  final int maxLoadedPages;
  final LinkedHashMap<int, VectorPage> _loadedPages = LinkedHashMap<int, VectorPage>();
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _evictionCount = 0;

  VectorLruCachePager({this.maxLoadedPages = 4});

  int get loadedPageCount => _loadedPages.length;
  int get cacheHits => _cacheHits;
  int get cacheMisses => _cacheMisses;
  int get evictionCount => _evictionCount;

  /// Loads or fetches a page, updating LRU recency.
  VectorPage accessPage(int pageId, {required VectorPage Function(int id) onDiskLoader}) {
    if (_loadedPages.containsKey(pageId)) {
      _cacheHits++;
      // Move to back (most recently used)
      final page = _loadedPages.remove(pageId)!;
      _loadedPages[pageId] = page;
      return page;
    }

    _cacheMisses++;
    if (_loadedPages.length >= maxLoadedPages) {
      // Evict least recently used (first key)
      final oldestKey = _loadedPages.keys.first;
      _loadedPages.remove(oldestKey);
      _evictionCount++;
    }

    final freshPage = onDiskLoader(pageId);
    _loadedPages[pageId] = freshPage;
    return freshPage;
  }

  /// Calculates cache hit ratio.
  double get hitRatio {
    final total = _cacheHits + _cacheMisses;
    return total > 0 ? (_cacheHits / total) : 0.0;
  }

  /// Clears cache completely.
  void clear() {
    _loadedPages.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
    _evictionCount = 0;
  }
}
