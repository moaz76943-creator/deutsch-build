import 'dart:collection';

class VectorPage {
  final int pageId;
  final Map<int, List<double>> vectors;
  bool isDirty;
  VectorPage({required this.pageId, Map<int, List<double>>? initialVectors, this.isDirty = false})
      : vectors = initialVectors ?? {};
  int get approximateMemoryBytes => 64 + (vectors.length * 160);
}

class LruVectorPager {
  final int maxMemoryBytes;
  final int vectorsPerPage;
  final LinkedHashMap<int, VectorPage> _activePages = LinkedHashMap<int, VectorPage>();
  int _cacheHits = 0;
  int _cacheMisses = 0;

  LruVectorPager({this.maxMemoryBytes = 8 * 1024 * 1024, this.vectorsPerPage = 128});

  int get loadedPageCount => _activePages.length;
  int get cacheHits => _cacheHits;
  int get cacheMisses => _cacheMisses;

  Future<List<double>?> getVector(int vectorId) async {
    final pageId = vectorId ~/ vectorsPerPage;
    if (_activePages.containsKey(pageId)) {
      _cacheHits++;
      final page = _activePages.remove(pageId)!;
      _activePages[pageId] = page;
      return page.vectors[vectorId];
    }
    _cacheMisses++;
    return null;
  }

  Future<void> putVector(int vectorId, List<double> vector) async {
    final pageId = vectorId ~/ vectorsPerPage;
    final page = _activePages.putIfAbsent(pageId, () => VectorPage(pageId: pageId));
    page.vectors[vectorId] = List.from(vector);
    page.isDirty = true;
  }
}
