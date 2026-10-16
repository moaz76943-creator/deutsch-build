import 'cache/lru_memory_cache.dart';

class CacheIdentity {
  const CacheIdentity({
    required this.language,
    this.direction = 'unknown',
    this.packVersion = 0,
  });

  final String language;
  final String direction;
  final int packVersion;

  @override
  bool operator ==(Object other) =>
      other is CacheIdentity &&
      language == other.language &&
      direction == other.direction &&
      packVersion == other.packVersion;

  @override
  int get hashCode => Object.hash(language, direction, packVersion);
}

/// Synchronous bounded L1 compatibility facade. Long-lived lexical data
/// belongs in SQLite/isolated workers, not an unbounded widget-side map.
class L1VocabularyCache {
  L1VocabularyCache._internal()
      : _memoryCache = LruMemoryCache<CacheIdentity,
            List<Map<String, dynamic>>>(
          maxCapacity: maximumIdentities,
          maxMemoryBudget: maximumEstimatedBytes,
          sizeEstimator: (_, value) => _estimate(value),
        );

  static final L1VocabularyCache _instance = L1VocabularyCache._internal();
  factory L1VocabularyCache() => _instance;

  static const int maximumIdentities = 50;
  static const int maximumEstimatedBytes = 5 * 1024 * 1024;
  static const int _maxNodes = 20000;
  final LruMemoryCache<CacheIdentity, List<Map<String, dynamic>>> _memoryCache;

  static int _estimate(Object? root) {
    var nodes = 0;
    int visit(Object? value, int depth) {
      if (++nodes > _maxNodes || depth > 8) return maximumEstimatedBytes + 1;
      if (value == null || value is bool || value is num) return 16;
      if (value is String) return 32 + value.length * 2;
      if (value is List) {
        var bytes = 48 + value.length * 8;
        for (final element in value) {
          bytes += visit(element, depth + 1);
          if (bytes > maximumEstimatedBytes) break;
        }
        return bytes;
      }
      if (value is Map) {
        var bytes = 72 + value.length * 16;
        for (final entry in value.entries) {
          if (entry.key is! String) return maximumEstimatedBytes + 1;
          bytes += visit(entry.key, depth + 1);
          bytes += visit(entry.value, depth + 1);
          if (bytes > maximumEstimatedBytes) break;
        }
        return bytes;
      }
      return maximumEstimatedBytes + 1; // Unknown mutable object: fail closed.
    }
    return visit(root, 0);
  }

  static Object? _freeze(Object? value) {
    if (value is List) {
      return List<Object?>.unmodifiable(value.map(_freeze));
    }
    if (value is Map) {
      final frozen = <String, dynamic>{};
      for (final entry in value.entries) {
        frozen[entry.key as String] = _freeze(entry.value);
      }
      return Map<String, dynamic>.unmodifiable(frozen);
    }
    return value;
  }

  void put(String langCode, List<Map<String, dynamic>> items,
      {String direction = 'unknown', int packVersion = 0}) {
    final key = CacheIdentity(
      language: langCode,
      direction: direction,
      packVersion: packVersion,
    );
    // Reject oversized inputs BEFORE copying nested values.
    if (langCode.isEmpty ||
        direction.isEmpty ||
        packVersion < 0 ||
        _estimate(items) > maximumEstimatedBytes) {
      return;
    }
    final immutableItems = List<Map<String, dynamic>>.unmodifiable(
        items.map((item) => _freeze(item)! as Map<String, dynamic>));
    _memoryCache.put(key, immutableItems);
  }

  List<Map<String, dynamic>>? get(String langCode,
      {String direction = 'unknown', int packVersion = 0}) =>
      _memoryCache.get(CacheIdentity(
          language: langCode, direction: direction, packVersion: packVersion));

  bool has(String langCode,
      {String direction = 'unknown', int packVersion = 0}) =>
      _memoryCache.containsKey(CacheIdentity(
          language: langCode, direction: direction, packVersion: packVersion));

  void invalidateStale(String langCode, String direction,
      int currentPackVersion) {
    final stale = _memoryCache.keys
        .where((identity) => identity.language == langCode &&
            identity.direction == direction &&
            identity.packVersion != currentPackVersion)
        .toList(growable: false);
    for (final key in stale) {
      _memoryCache.remove(key);
    }
  }

  int get length => _memoryCache.length;
  int get estimatedMemoryUsageBytes => _memoryCache.currentMemory;
  int get retainedIdentities => _memoryCache.length;
  void onMemoryPressure() => _memoryCache.onMemoryPressure();
  void clear() => _memoryCache.clear();
}
