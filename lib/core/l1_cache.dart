import 'package:deutsch_bilarabi/core/cache/cache_identity.dart';
import 'package:deutsch_bilarabi/core/cache/lru_memory_cache.dart';

class L1VocabularyCache {
  static final L1VocabularyCache _instance = L1VocabularyCache._internal();
  factory L1VocabularyCache() => _instance;

  L1VocabularyCache._internal() {
    _memoryCache = LruMemoryCache<String, List<Map<String, dynamic>>>(
      maxCapacity: 20,
      maxMemoryBytes: 15 * 1024 * 1024, // 15MB budget
      onEvict: (key) {
        _identities.remove(key);
      },
      sizeEstimator: (k, v) => _measureSize(v),
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

  String generateKey(String language, String direction, String contentVersion) {
    return '${language}_${direction}_$contentVersion';
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

    _invalidateStaleIdentity(identity);

    if (_memoryCache.put(langCode, List.unmodifiable(items))) {
        _identities[langCode] = identity;
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

  void invalidateStaleVersions(String activeVersion) {
    final keysToRemove = <String>[];
    // use memoryCache keys as identities could be empty in legacy fallback mode
    for (final key in _memoryCache.keys) {
      if (key.split('_').length >= 3) { // It's a generated key
         if (key.split('_').last != activeVersion) {
            keysToRemove.add(key);
         }
      } else if (_identities.containsKey(key)) {
         if (_identities[key]!.contentVersion != activeVersion) {
             keysToRemove.add(key);
         }
      }
    }

    for (final k in keysToRemove) {
      _memoryCache.remove(k);
      _identities.remove(k);
    }
  }

  // Legacy fallback and other overloads
  void put(String key, List<Map<String, dynamic>> items, {String? direction, int? packVersion, int? requestEpoch, int? activeEpoch}) {
    if (requestEpoch != null && activeEpoch != null && requestEpoch < activeEpoch) {
      return; // reject stale asynchronous update
    }

    String finalKey = key;
    if (direction != null && packVersion != null) {
      finalKey = generateKey(key, direction, packVersion.toString());
    }

    if (_memoryCache.put(finalKey, List.unmodifiable(items))) {
       if (direction != null) {
           _identities[finalKey] = CacheIdentity(language: key, direction: direction, pairEpoch: activeEpoch ?? 0, contentVersion: packVersion?.toString() ?? 'unknown');
       }
    }
  }

  List<Map<String, dynamic>>? get(String key, {String? direction, int? packVersion}) {
    String finalKey = key;
    if (direction != null && packVersion != null) {
      finalKey = generateKey(key, direction, packVersion.toString());
    } else if (direction != null) {
        if (!_memoryCache.containsKey(finalKey)) {
             for(var id in _identities.values){
                 if(id.language == key && id.direction == direction){
                     return _memoryCache.get(_identities.entries.firstWhere((e)=>e.value==id).key);
                 }
             }
        }
    }

    // ensure no cross pair retrieval
    if (direction != null) {
        if (_identities.containsKey(finalKey)) {
            if (_identities[finalKey]!.direction != direction) {
                return null;
            }
        } else {
            // trying to check identities for older signature
            for(var id in _identities.values){
                if(id.language == key && id.direction != direction){
                    return null; // found wrong direction
                }
            }
        }
    }
    return _memoryCache.get(finalKey);
  }

  bool has(String key, {String? direction, int? packVersion}) {
    String finalKey = key;
    if (direction != null && packVersion != null) {
      finalKey = generateKey(key, direction, packVersion.toString());
    } else if (direction != null) {
        if (!_memoryCache.containsKey(finalKey)) {
             for(var id in _identities.values){
                 if(id.language == key && id.direction == direction){
                     return _memoryCache.containsKey(_identities.entries.firstWhere((e)=>e.value==id).key);
                 }
             }
        }
    }

    // ensure no cross pair retrieval
    if (direction != null) {
        if (_identities.containsKey(finalKey)) {
            if (_identities[finalKey]!.direction != direction) {
                return false;
            }
        } else {
            for(var id in _identities.values){
                if(id.language == key && id.direction != direction){
                    return false; // found wrong direction
                }
            }
        }
    }
    return _memoryCache.containsKey(finalKey);
  }

  void invalidateStale(String lang, String direction, int packVersion) {
    final keysToRemove = <String>[];
    for (final key in _memoryCache.keys) {
      if (key.startsWith('${lang}_') && key != generateKey(lang, direction, packVersion.toString())) {
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
    // _identities is implicitly cleared via onEvict callbacks
  }

  void trimMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }

  void onMemoryPressure() {
      _memoryCache.onMemoryPressure();
  }

  int get currentMemoryBytes => _memoryCache.currentMemoryBytes;
}
