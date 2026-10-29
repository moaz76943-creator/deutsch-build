class L1VocabularyCache {
  static final L1VocabularyCache _instance = L1VocabularyCache._internal();
  factory L1VocabularyCache() => _instance;
  L1VocabularyCache._internal();

  final Map<String, List<Map<String, dynamic>>> _memoryCache = {};

  void put(String langCode, List<Map<String, dynamic>> items) {
    _memoryCache[langCode] = List.unmodifiable(items);
  }

  List<Map<String, dynamic>>? get(String langCode) {
    return _memoryCache[langCode];
  }

  bool has(String langCode) => _memoryCache.containsKey(langCode);

  void clear() {
    _memoryCache.clear();
  }
}
