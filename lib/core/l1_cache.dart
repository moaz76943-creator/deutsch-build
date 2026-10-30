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
    );
  }

  int get currentMemoryBytes => _memoryCache.currentMemoryBytes;

  String generateKey(String language, String direction, String contentVersion) {
    return '${language}_${direction}_$contentVersion';
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

    final size = _measureSize(items);
    final success = _memoryCache.put(langCode, List.unmodifiable(items), itemSizeBytes: size);
    if (success) {
      _identities[langCode] = identity;
    }
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

  void invalidateStaleVersions(String currentVersion) {
    final keysToRemove = <String>[];
    for (final entry in _identities.entries) {
      if (entry.value.contentVersion != currentVersion) {
        keysToRemove.add(entry.key);
      }
    }
    for (final k in keysToRemove) {
      _memoryCache.remove(k);
      _identities.remove(k);
    }
  }

  void invalidateStale(String language, String direction, int currentPackVersion) {
      final keysToRemove = <String>[];
      for (final entry in _identities.entries) {
          final id = entry.value;
          if (id.language == language && id.direction == direction) {
              // Parse semver or use exact match since content version is a string.
              // For legacy fallback: if currentPackVersion is 2, it invalidates everything not '2'.
              if (id.contentVersion != currentPackVersion.toString()) {
                  keysToRemove.add(entry.key);
              }
          }
      }
      for (final k in keysToRemove) {
          _memoryCache.remove(k);
          _identities.remove(k);
      }
  }

  // Legacy fallback and generic put supporting new tests
  void put(
    String langOrKey,
    List<Map<String, dynamic>> items, {
    String? direction,
    int? packVersion,
    int? requestEpoch,
    int? activeEpoch,
  }) {
    if (requestEpoch != null && activeEpoch != null && requestEpoch != activeEpoch) {
      return; // Reject stale asynchronous update
    }

    String key = langOrKey;
    String lang = langOrKey;
    String dir = direction ?? 'default';
    String version = packVersion?.toString() ?? '1.0.0';

    if (direction != null || packVersion != null) {
      key = generateKey(lang, dir, version);
    }

    final identity = CacheIdentity(
      language: lang,
      direction: dir,
      contentVersion: version,
      pairEpoch: requestEpoch ?? 0,
    );

    final size = _measureSize(items);
    final success = _memoryCache.put(key, List.unmodifiable(items), itemSizeBytes: size);
    if (success) {
        _identities[key] = identity;
    }
  }

  List<Map<String, dynamic>>? get(String langOrKey, {String? direction, int? packVersion}) {
    if (direction != null || packVersion != null) {
      final lang = langOrKey;
      final dir = direction ?? 'default';
      final version = packVersion?.toString() ?? '1.0.0';
      final key = generateKey(lang, dir, version);
      return _memoryCache.get(key);
    }
    return _memoryCache.get(langOrKey);
  }

  bool has(String langOrKey, {String? direction, int? packVersion}) {
    if (direction != null || packVersion != null) {
      final lang = langOrKey;
      final dir = direction ?? 'default';
      final version = packVersion?.toString() ?? '1.0.0';
      final key = generateKey(lang, dir, version);
      return _memoryCache.containsKey(key);
    }
    return _memoryCache.containsKey(langOrKey);
  }

  void clear() {
    _memoryCache.clear();
    // _identities is implicitly cleared via onEvict callbacks
  }

  void onMemoryPressure() {
      trimMemoryPressure();
  }

  void trimMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }
}
