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
      onEvict: (key) {
        _identities.remove(key);
      },
      sizeEstimator: (k, v) => _measureSize(v),
    );
  }

  int _measureSize(List<Map<String, dynamic>> items) {
    int size = 0;
    for (final item in items) {
      for (final entry in item.entries) {
        size += entry.key.length * 2;
        if (entry.value is String) {
          size += (entry.value as String).length * 2;
        } else if (entry.value is num) {
          size += 8;
        } else if (entry.value is bool) {
          size += 1;
        } else {
          size += 16;
        }
      }
    }
    return size;
  }

  String generateKey(String language, String direction, String contentVersion) {
    return '${language}_${direction}_$contentVersion';
  }

  int get currentMemoryBytes => _memoryCache.currentMemoryBytes;

  String _getFinalKey(String key, {String? direction, dynamic packVersion}) {
    if (direction != null) {
      return generateKey(key, direction, packVersion?.toString() ?? 'null');
    }
    return key;
  }

  void putWithIdentity(String langCode, List<Map<String, dynamic>> items,
      CacheIdentity identity) {
    final finalKey = generateKey(langCode, identity.direction, identity.contentVersion);

    if (_identities.containsKey(finalKey)) {
      final existingIdentity = _identities[finalKey]!;
      if (existingIdentity.language == identity.language &&
          existingIdentity.direction == identity.direction &&
          existingIdentity.contentVersion == identity.contentVersion &&
          existingIdentity.pairEpoch > identity.pairEpoch) {
        return;
      }
    }

    _invalidateStaleIdentity(identity);

    if (_memoryCache.put(finalKey, List.unmodifiable(items))) {
      _identities[finalKey] = identity;
    }
  }

  void _invalidateStaleIdentity(CacheIdentity newIdentity) {
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

  void put(
    String key,
    List<Map<String, dynamic>> items, {
    int? requestEpoch,
    int? activeEpoch,
    String? direction,
    dynamic packVersion,
  }) {
    if (requestEpoch != null && activeEpoch != null && requestEpoch < activeEpoch) {
      return;
    }

    final finalKey = _getFinalKey(key, direction: direction, packVersion: packVersion);
    _memoryCache.put(finalKey, List.unmodifiable(items));
  }

  List<Map<String, dynamic>>? get(String key, {String? direction, dynamic packVersion}) {
    final finalKey = _getFinalKey(key, direction: direction, packVersion: packVersion);

    if (_memoryCache.containsKey(finalKey)) {
      return _memoryCache.get(finalKey);
    }

    if (_memoryCache.containsKey(key)) {
      return _memoryCache.get(key);
    }
    return null;
  }

  bool has(String key, {String? direction, dynamic packVersion}) {
    final finalKey = _getFinalKey(key, direction: direction, packVersion: packVersion);
    return _memoryCache.containsKey(finalKey) || _memoryCache.containsKey(key);
  }

  void invalidateStaleVersions(String version) {
    final keysToRemove = <String>[];
    for (final key in _memoryCache.keys) {
      if (!key.endsWith('_$version')) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }
  }

  void invalidateStale(String lang, String direction, dynamic packVersion) {
    final prefix = '${lang}_${direction}_';
    final currentKey = generateKey(lang, direction, packVersion.toString());
    final keysToRemove = <String>[];

    for (final key in _memoryCache.keys) {
      if (key.startsWith(prefix) && key != currentKey) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }
  }

  void clear() {
    _memoryCache.clear();
  }

  void trimMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }

  void onMemoryPressure() {
    trimMemoryPressure();
  }
}
