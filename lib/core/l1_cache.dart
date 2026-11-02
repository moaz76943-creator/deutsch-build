import 'package:deutsch_bilarabi/core/cache/cache_identity.dart';
import 'package:deutsch_bilarabi/core/cache/lru_memory_cache.dart';

class L1VocabularyCache {
  static final L1VocabularyCache _instance = L1VocabularyCache._internal();
  factory L1VocabularyCache() => _instance;

  L1VocabularyCache._internal() {
    _memoryCache = LruMemoryCache<String, List<Map<String, dynamic>>>(
      maxCapacity: 50, // Reduced max capacity for 100-lang memory pressure requirements
      maxMemoryBytes: 5 * 1024 * 1024, // 5MB budget
      onEvict: (key) {
        _identities.remove(key);
      },
    );
  }

  late final LruMemoryCache<String, List<Map<String, dynamic>>> _memoryCache;

  final Map<String, CacheIdentity> _identities = {};

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

  String _generateKey(String langCode, {String? direction, dynamic packVersion}) {
    if (direction != null || packVersion != null) {
      // If we don't have direction or packVersion, we shouldn't map them identically to a plain langCode.
      // But legacy code might call it without them.
      return '${langCode}::${direction ?? 'none'}::${packVersion ?? 'none'}';
    }
    return langCode;
  }

  String generateKey(String language, String direction, String contentVersion) {
     return '${language}::${direction}::$contentVersion';
  }

  void putWithIdentity(String langCode, List<Map<String, dynamic>> items,
      CacheIdentity identity) {
    final key = _generateKey(langCode, direction: identity.direction, packVersion: identity.contentVersion);

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

    _invalidateStale(identity);

    final size = _measureSize(items);
    _memoryCache.put(key, List.unmodifiable(items), itemSizeBytes: size);
    _identities[key] = identity;
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

  // Legacy fallback
  void put(String langCode, List<Map<String, dynamic>> items, {String? direction, dynamic packVersion, int? requestEpoch, int? activeEpoch}) {
    if (requestEpoch != null && activeEpoch != null && requestEpoch < activeEpoch) {
      return;
    }
    final key = _generateKey(langCode, direction: direction, packVersion: packVersion);

    // Attempt to track manual keys for invalidation if direction is provided
    if (direction != null) {
       _identities[key] = CacheIdentity(
           language: langCode,
           direction: direction,
           pairEpoch: requestEpoch ?? 0,
           contentVersion: packVersion?.toString() ?? 'none'
       );
    }
    _memoryCache.put(key, List.unmodifiable(items),
        itemSizeBytes: _measureSize(items));
  }

  List<Map<String, dynamic>>? get(String langCode, {String? direction, dynamic packVersion}) {
    final key = _generateKey(langCode, direction: direction, packVersion: packVersion);
    return _memoryCache.get(key);
  }

  bool has(String langCode, {String? direction, dynamic packVersion}) {
    final key = _generateKey(langCode, direction: direction, packVersion: packVersion);
    return _memoryCache.containsKey(key);
  }

  void clear() {
    _memoryCache.clear();
    // _identities is implicitly cleared via onEvict callbacks
  }

  void trimMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }

  void onMemoryPressure() {
    trimMemoryPressure();
  }

  void invalidateStaleVersions(String currentVersion) {
    final keysToRemove = <String>[];
    for (final key in _identities.keys) {
      final id = _identities[key]!;
      if (id.contentVersion != currentVersion) {
        keysToRemove.add(key);
      }
    }

    // Also remove from _memoryCache any keys that end with an old version suffix, since they may not be tracked in _identities.
    for (final key in _memoryCache.keys) {
      if (key.contains('::')) {
          final parts = key.split('::');
          if (parts.length >= 3) {
             final ver = parts.last;
             if (ver != currentVersion && ver != 'none') {
                keysToRemove.add(key);
             }
          }
      }
    }

    for (final k in keysToRemove) {
      _memoryCache.remove(k);
      _identities.remove(k);
    }
  }

  void invalidateStale(String language, String direction, dynamic packVersion) {
     final keysToRemove = <String>[];
     final targetVersion = packVersion?.toString() ?? 'none';
     for (final key in _identities.keys) {
        final id = _identities[key]!;
        if (id.language == language && id.direction == direction && id.contentVersion != targetVersion) {
            keysToRemove.add(key);
        }
     }

     // Also remove from _memoryCache directly if not tracked in _identities
     for (final key in _memoryCache.keys) {
        if (key.startsWith('${language}::${direction}::') && !key.endsWith('::$targetVersion')) {
            keysToRemove.add(key);
        }
     }

     for (final k in keysToRemove) {
        _memoryCache.remove(k);
        _identities.remove(k);
     }
  }

  int get currentMemoryBytes => _memoryCache.currentMemoryBytes;
}
