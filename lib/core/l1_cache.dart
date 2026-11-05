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
      sizeEstimator: (key, value) => _measureSize(value),
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

  String generateKey(String language, String direction, dynamic contentVersion) {
    return '${language}_${direction}_$contentVersion';
  }

  String _buildKey(String langCode, String? direction, dynamic packVersion) {
    if (direction == null && packVersion == null) return langCode;
    return '${langCode}_${direction ?? ''}_${packVersion ?? ''}';
  }

  void putWithIdentity(String langCode, List<Map<String, dynamic>> items, CacheIdentity identity) {
    final key = _buildKey(langCode, identity.direction, identity.contentVersion);

    // Check if stale
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
    String langCode,
    List<Map<String, dynamic>> items, {
    int? requestEpoch,
    int? activeEpoch,
    String? direction,
    dynamic packVersion,
  }) {
    if (requestEpoch != null && activeEpoch != null && requestEpoch < activeEpoch) {
      return; // reject stale asynchronous update
    }

    final key = _buildKey(langCode, direction, packVersion);
    _memoryCache.put(key, List.unmodifiable(items));
  }

  List<Map<String, dynamic>>? get(String langCode, {String? direction, dynamic packVersion}) {
    final key = _buildKey(langCode, direction, packVersion);
    return _memoryCache.get(key);
  }

  bool has(String langCode, {String? direction, dynamic packVersion}) {
    final key = _buildKey(langCode, direction, packVersion);
    return _memoryCache.containsKey(key);
  }

  void invalidateStale(String language, String direction, dynamic version) {
    final keysToRemove = <String>[];
    // Strip trailing underscores if language was generated with empty padding
    final baseLang = language.endsWith('__') ? language.substring(0, language.length - 2) : language;
    final prefix = '${baseLang}_${direction}_';
    final suffix = '_$version';

    for (final key in _memoryCache.keys) {
      if (key.startsWith(prefix) && !key.endsWith(suffix)) {
        keysToRemove.add(key);
      }
    }
    for (final k in keysToRemove) {
      _memoryCache.remove(k);
      _identities.remove(k);
    }
  }

  void clear() {
    _memoryCache.clear();
    _identities.clear();
  }

  void trimMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }

  void onMemoryPressure() {
    trimMemoryPressure();
  }

  int get currentMemoryBytes => _memoryCache.currentMemoryBytes;
}
