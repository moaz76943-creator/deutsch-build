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
      maxMemoryBytes: 15 * 1024 * 1024, // 15MB budget
      sizeEstimator: (k, v) => _measureSize(v),
      onEvict: (key) {
        _identities.remove(key);
      }
    );
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

  String generateKey(String langCode, String direction, String packVersion) {
    return '${langCode}_${direction}_$packVersion';
  }

  void putWithIdentity(String langCode, List<Map<String, dynamic>> items, CacheIdentity identity) {
    final key = generateKey(langCode, identity.direction, identity.contentVersion);

    if (_identities.containsKey(key)) {
      final existingIdentity = _identities[key]!;
      if (existingIdentity.language == identity.language &&
          existingIdentity.direction == identity.direction &&
          existingIdentity.contentVersion == identity.contentVersion &&
          existingIdentity.pairEpoch > identity.pairEpoch) {
        return; // Reject stale asynchronous update
      }
    }

    _invalidateStaleIdentity(identity);

    _memoryCache.put(key, List.unmodifiable(items));
    _identities[key] = identity;
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
    String keyOrLangCode,
    List<Map<String, dynamic>> items, {
    String? direction,
    dynamic packVersion,
    int? requestEpoch,
    int? activeEpoch,
  }) {
    if (requestEpoch != null && activeEpoch != null && requestEpoch < activeEpoch) {
      return; // Reject stale asynchronous update
    }

    String key = keyOrLangCode;
    if (direction != null) {
      key = generateKey(keyOrLangCode, direction, packVersion?.toString() ?? '');
    }

    _memoryCache.put(key, List.unmodifiable(items));
  }

  List<Map<String, dynamic>>? get(
    String keyOrLangCode, {
    String? direction,
    dynamic packVersion,
  }) {
    String key = keyOrLangCode;
    if (direction != null) {
      key = generateKey(keyOrLangCode, direction, packVersion?.toString() ?? '');
    }
    return _memoryCache.get(key);
  }

  bool has(
    String keyOrLangCode, {
    String? direction,
    dynamic packVersion,
  }) {
    String key = keyOrLangCode;
    if (direction != null) {
      key = generateKey(keyOrLangCode, direction, packVersion?.toString() ?? '');
    }
    return _memoryCache.containsKey(key);
  }

  void invalidateStale(String langCode, String direction, int currentPackVersion) {
    final prefix = '${langCode}_${direction}_';
    final keysToRemove = <String>[];
    for (final key in _memoryCache.keys) {
      if (key.startsWith(prefix)) {
        final versionStr = key.substring(prefix.length);
        if (versionStr != currentPackVersion.toString()) {
          keysToRemove.add(key);
        }
      }
    }
    for (final k in keysToRemove) {
      _memoryCache.remove(k);
    }
  }

  void invalidateStaleVersions(String currentPackVersion) {
    final keysToRemove = <String>[];
    for (final key in _memoryCache.keys) {
      final parts = key.split('_');
      if (parts.length >= 3) {
        final version = parts.last;
        if (version != currentPackVersion) {
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
    _identities.clear();
  }

  void onMemoryPressure() {
    _memoryCache.onMemoryPressure();
  }

  void trimMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }

  int get currentMemoryBytes => _memoryCache.currentMemoryBytes;
}
