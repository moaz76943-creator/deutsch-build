import 'cache/lru_memory_cache.dart';

class L1VocabularyCache {
  static final L1VocabularyCache _instance = L1VocabularyCache._internal();
  factory L1VocabularyCache() => _instance;

  late final LruMemoryCache<String, List<Map<String, dynamic>>> _memoryCache;

  L1VocabularyCache._internal() {
    _memoryCache = LruMemoryCache<String, List<Map<String, dynamic>>>(
      maxCapacity: 20, // Reasonable number of active caches (e.g. 20 direction pairs)
      maxMemoryBytes: 15 * 1024 * 1024, // 15 MB total budget
      sizeEstimator: (key, items) {
        // Approximate size: ~100 bytes per vocabulary item + some overhead
        int size = 0;
        for (final item in items) {
          // Add a base size for map structure and some average lengths for values
          size += 100;
          for (final val in item.values) {
              if (val is String) {
                  size += val.length * 2; // Dart uses UTF-16
              } else if (val is num) {
                  size += 8;
              } else if (val is bool) {
                  size += 4;
              } else {
                  size += 32; // arbitrary pointer/object overhead
              }
          }
        }
        return size;
      },
    );
  }

  /// Generates a cache key based on source, target and semantic content version
  String generateKey(String sourceLocale, String targetLocale, String semanticVersion) {
    return '${sourceLocale}_${targetLocale}_$semanticVersion';
  }

  /// Puts an item into the cache.
  /// The `requestEpoch` and `activeEpoch` prevent stale asynchronous mutations
  /// from writing old data to the cache if the active epoch has changed.
  void put(
    String cacheKey,
    List<Map<String, dynamic>> items, {
    int? requestEpoch,
    int? activeEpoch,
  }) {
    if (requestEpoch != null && activeEpoch != null && requestEpoch != activeEpoch) {
      return; // Reject stale async mutation
    }
    _memoryCache.put(cacheKey, List.unmodifiable(items));
  }

  List<Map<String, dynamic>>? get(String cacheKey) {
    return _memoryCache.get(cacheKey);
  }

  bool has(String cacheKey) => _memoryCache.containsKey(cacheKey);

  void invalidateStaleVersions(String activeVersion) {
    final keysToRemove = _memoryCache.keys.where((key) => !key.endsWith('_$activeVersion')).toList();
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }
  }

  void onMemoryPressure() {
      _memoryCache.onMemoryPressure();
  }

  void clear() {
    _memoryCache.clear();
  }

  // For testing
  int get currentMemoryBytes => _memoryCache.currentMemoryBytes;
}