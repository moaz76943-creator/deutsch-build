import 'package:deutsch_bilarabi/core/cache/cache_identity.dart';
import 'package:deutsch_bilarabi/core/cache/lru_memory_cache.dart';

class L1VocabularyCache {
  static final L1VocabularyCache _instance = L1VocabularyCache._internal();
  factory L1VocabularyCache() => _instance;

  late final LruMemoryCache<String, List<Map<String, dynamic>>> _memoryCache;
  final Map<String, CacheIdentity> _identities = {};


  L1VocabularyCache._internal() {
    _memoryCache = LruMemoryCache<String, List<Map<String, dynamic>>>(
      maxCapacity: 50,
      maxMemoryBytes: 5 * 1024 * 1024, // 5MB budget
      sizeEstimator: (k, v) => _measureSize(v),
      onEvict: (key) {
        _identities.remove(key);
      },
    );
  }

  int _measureSize(List<Map<String, dynamic>> items) {
    int size = 0;
    for (final item in items) {
      for (final entry in item.entries) {
        size += entry.key.length * 2; // ~2 bytes per char
        if (entry.value is String) {
          size += (entry.value as String).length * 2;
        } else if (entry.value is num) {
          size += 8; // 8 bytes for double/int
        } else if (entry.value is bool) {
          size += 1;
        } else {
          size += 16; // rough fallback
        }
      }
    }
    return size;
  }

  String generateKey(String language, String direction, String contentVersion) {
    return '${language}_${direction}_$contentVersion';
  }

  void putWithIdentity(String key, List<Map<String, dynamic>> items,
      CacheIdentity identity) {
    // Check if stale asynchronous update
    if (_identities.containsKey(key)) {
      final existingIdentity = _identities[key]!;
      if (existingIdentity.language == identity.language &&
          existingIdentity.direction == identity.direction &&
          existingIdentity.contentVersion == identity.contentVersion &&
          existingIdentity.pairEpoch > identity.pairEpoch) {
        return; // Reject stale asynchronous update
      }
    }

    _invalidateStaleForNewIdentity(identity);

    if (_memoryCache.put(key, List.unmodifiable(items))) {
      _identities[key] = identity;
    }
  }

  void _invalidateStaleForNewIdentity(CacheIdentity newIdentity) {
    final keysToRemove = <String>[];
    for (final entry in _identities.entries) {
      final id = entry.value;
      if (id.language == newIdentity.language &&
          id.direction == newIdentity.direction) {
        if (id.contentVersion != newIdentity.contentVersion ||
            id.pairEpoch < newIdentity.pairEpoch) {
          keysToRemove.add(entry.key);
        }
      }
    }
    for (final k in keysToRemove) {
      _memoryCache.remove(k);
      _identities.remove(k);
    }
  }

  void invalidateStaleVersions(String currentContentVersion) {
    final keysToRemove = <String>[];
    for (final entry in _identities.entries) {
      if (entry.value.contentVersion != currentContentVersion) {
        keysToRemove.add(entry.key);
      }
    }
    for (final k in keysToRemove) {
      _memoryCache.remove(k);
      _identities.remove(k);
    }
  }

  void put(
    String key,
    List<Map<String, dynamic>> items,
    {int? requestEpoch, int? activeEpoch}
  ) {
    if (requestEpoch != null && activeEpoch != null) {
      if (requestEpoch < activeEpoch) {
        return; // Stale mutation
      }
    }
    _memoryCache.put(key, List.unmodifiable(items));

    // Attempt to extract language and direction from key (assume format: {lang}_{dir}_{version})
    final parts = key.split('_');
    if (parts.length >= 3) {
      _identities[key] = CacheIdentity(
        language: parts[0],
        direction: parts[1],
        contentVersion: parts[2],
        pairEpoch: requestEpoch ?? activeEpoch ?? 0,
      );
    }
  }

  List<Map<String, dynamic>>? get(String key) {
    return _memoryCache.get(key);
  }

  bool has(String key) => _memoryCache.containsKey(key);

  void clear() {
    _memoryCache.clear();
    _identities.clear();
  }

  void onMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }

  void trimMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }

  int get currentMemoryBytes => _memoryCache.currentMemoryBytes;
}
