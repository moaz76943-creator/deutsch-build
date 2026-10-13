import 'cache/lru_memory_cache.dart';

class CacheIdentity {
  final String language;
  final String direction;
  final int packVersion;

  const CacheIdentity({
    required this.language,
    this.direction = 'unknown',
    this.packVersion = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheIdentity &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          direction == other.direction &&
          packVersion == other.packVersion;

  @override
  int get hashCode =>
      language.hashCode ^ direction.hashCode ^ packVersion.hashCode;

  @override
  String toString() {
    return 'CacheIdentity(language: $language, direction: $direction, packVersion: $packVersion)';
  }
}

class L1VocabularyCache {
  static final L1VocabularyCache _instance = L1VocabularyCache._internal();
  factory L1VocabularyCache() => _instance;

  // Expose cache capacity for configuration if needed.
  // Let's cap at 50 identities, and e.g., 5MB.
  final LruMemoryCache<CacheIdentity, List<Map<String, dynamic>>> _memoryCache;

  L1VocabularyCache._internal()
      : _memoryCache = LruMemoryCache<CacheIdentity, List<Map<String, dynamic>>>(
          maxCapacity: 50, // Enough for multiple languages/directions
          maxMemoryBudget: 5 * 1024 * 1024, // 5MB total budget roughly estimated
          sizeEstimator: (key, value) {
            // Rough size estimator
            int size = 0;
            for (var item in value) {
              size += 64; // Map overhead overhead per entry roughly
              item.forEach((k, v) {
                size += k.length * 2;
                if (v is String) {
                  size += v.length * 2;
                } else if (v is int || v is double || v is bool) {
                  size += 8;
                }
              });
            }
            return size;
          },
        );

  void put(String langCode, List<Map<String, dynamic>> items, {String direction = 'unknown', int packVersion = 0}) {
    final identity = CacheIdentity(
      language: langCode,
      direction: direction,
      packVersion: packVersion,
    );
    _memoryCache.put(identity, List.unmodifiable(items));
  }

  List<Map<String, dynamic>>? get(String langCode, {String direction = 'unknown', int packVersion = 0}) {
    final identity = CacheIdentity(
      language: langCode,
      direction: direction,
      packVersion: packVersion,
    );
    return _memoryCache.get(identity);
  }

  bool has(String langCode, {String direction = 'unknown', int packVersion = 0}) {
    final identity = CacheIdentity(
      language: langCode,
      direction: direction,
      packVersion: packVersion,
    );
    return _memoryCache.containsKey(identity);
  }

  void invalidateStale(String langCode, String direction, int currentPackVersion) {
    final keysToRemove = _memoryCache.keys.where((k) =>
        k.language == langCode &&
        k.direction == direction &&
        k.packVersion != currentPackVersion).toList();

    for (var k in keysToRemove) {
      _memoryCache.remove(k);
    }
  }

  void onMemoryPressure() {
    _memoryCache.onMemoryPressure();
  }

  void clear() {
    _memoryCache.clear();
  }
}
