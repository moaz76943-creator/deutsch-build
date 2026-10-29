import 'dart:collection';

class L1VocabularyCache {
  static final L1VocabularyCache _instance = L1VocabularyCache._internal();
  factory L1VocabularyCache() => _instance;
  L1VocabularyCache._internal();

  static const int defaultMaxCapacity = 3;
  final int maxCapacity = defaultMaxCapacity;
  final LinkedHashMap<String, List<Map<String, dynamic>>> _memoryCache =
      LinkedHashMap<String, List<Map<String, dynamic>>>();

  void put(String langCode, List<Map<String, dynamic>> items) {
    if (_memoryCache.containsKey(langCode)) {
      _memoryCache.remove(langCode);
    } else if (_memoryCache.length >= maxCapacity) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[langCode] = List.unmodifiable(items);
  }

  List<Map<String, dynamic>>? get(String langCode) {
    if (!_memoryCache.containsKey(langCode)) return null;
    final value = _memoryCache.remove(langCode)!;
    _memoryCache[langCode] = value;
    return value;
  }

  bool has(String langCode) => _memoryCache.containsKey(langCode);

  int get length => _memoryCache.length;

  void clear() {
    _memoryCache.clear();
  }
}
