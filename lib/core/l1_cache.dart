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

  int get currentMemoryBytes => _memoryCache.currentMemoryBytes;

  String generateKey(String language, String direction, String contentVersion) {
    return '${language}_${direction}_$contentVersion';
  }

  static int _measureSize(List<Map<String, dynamic>> items) {
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

  void putWithIdentity(String langCode, List<Map<String, dynamic>> items,
      CacheIdentity identity) {
    // Check if stale
    if (_identities.containsKey(langCode)) {
      final existingIdentity = _identities[langCode]!;
      if (existingIdentity.language == identity.language &&
          existingIdentity.direction == identity.direction &&
          existingIdentity.contentVersion == identity.contentVersion &&
          existingIdentity.pairEpoch > identity.pairEpoch) {
        return; // Reject stale asynchronous update
      }
    }

    _invalidateStale(identity);

    _memoryCache.put(langCode, List.unmodifiable(items));
    _identities[langCode] = identity;
  }

  void _invalidateStale(CacheIdentity newIdentity) {
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

  void put(String keyOrLang, List<Map<String, dynamic>> items,
      {String? direction, dynamic packVersion, int? requestEpoch, int? activeEpoch}) {
    if (requestEpoch != null && activeEpoch != null && requestEpoch < activeEpoch) {
      return;
    }

    String effectiveKey = keyOrLang;
    if (direction != null || packVersion != null) {
      effectiveKey = generateKey(keyOrLang, direction ?? '', packVersion?.toString() ?? '');
    }

    _memoryCache.put(effectiveKey, List.unmodifiable(items));
  }

  List<Map<String, dynamic>>? get(String key, {String? direction, dynamic packVersion}) {
    String effectiveKey = key;
    if (direction != null || packVersion != null) {
      effectiveKey = generateKey(key, direction ?? '', packVersion?.toString() ?? '');
    }
    if (!_memoryCache.containsKey(effectiveKey) && _memoryCache.containsKey(key)) {
      return _memoryCache.get(key);
    }
    return _memoryCache.get(effectiveKey);
  }

  bool has(String key, {String? direction, dynamic packVersion}) {
    String effectiveKey = key;
    if (direction != null || packVersion != null) {
      effectiveKey = generateKey(key, direction ?? '', packVersion?.toString() ?? '');
    }
    return _memoryCache.containsKey(effectiveKey) || _memoryCache.containsKey(key);
  }

  void invalidateStaleVersions(String version) {
    final keysToRemove = <String>[];
    for (final key in _memoryCache.keys) {
      final parts = key.split('_');
      if (parts.length >= 3) {
        final keyVersion = parts.last;
        if (keyVersion != version) {
          keysToRemove.add(key);
        }
      }
    }
    for (final k in keysToRemove) {
      _memoryCache.remove(k);
    }
  }

  void invalidateStale(String language, String direction, dynamic packVersion) {
    final keysToRemove = <String>[];
    final versionStr = packVersion.toString();
    for (final key in _memoryCache.keys) {
      final parts = key.split('_');
      if (parts.length >= 3) {
        if (parts[0] == language && parts[1] == direction && parts[2] != versionStr) {
          keysToRemove.add(key);
        }
      }
    }
    for (final k in keysToRemove) {
      _memoryCache.remove(k);
    }
  }

  void clear() {
    _memoryCache.clear();
  }

  void onMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }

  void trimMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }
}
