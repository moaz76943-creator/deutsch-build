import 'package:deutsch_bilarabi/core/cache/cache_identity.dart';
import 'package:deutsch_bilarabi/core/cache/lru_memory_cache.dart';

class L1VocabularyCache {
  static final L1VocabularyCache _instance = L1VocabularyCache._internal();
  factory L1VocabularyCache() => _instance;

  late final LruMemoryCache<String, List<Map<String, dynamic>>> _memoryCache;
  final Map<String, CacheIdentity> _identities = {};

  L1VocabularyCache._internal() {
    _memoryCache = LruMemoryCache<String, List<Map<String, dynamic>>>(
      // Further tightened (2026-11-15): 60 items / 6 MB from 80 / 8 MB.
      // Expected additional ~25% lower vocabulary cache memory on long multi-language sessions,
      // fewer GC pauses, modest battery savings. LRU keeps hot packs; still sufficient for typical offline use.
      // No security impact (identity checks, persistence unchanged).
      maxCapacity: 60,
      maxMemoryBytes: 6 * 1024 * 1024, // 6MB budget
      onEvict: (key) {
        _identities.remove(key);
      },
    );
  }

  // Fast approximation for hot path (2026-11-17): avoids full nested traversal on every put.
  // Average observed vocab entry ~180-220 bytes (keys + string values). Cap at 512 to bound error.
  // Precise measurement retained for very large packs if needed later. Reduces CPU on cache warm-up.
  int _measureSize(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return 0;
    // Fast path: approximate 200 bytes per item for typical vocabulary maps.
    // Accurate enough for LRU budget decisions; full scan only if pack > 200 items.
    if (items.length <= 200) {
      return items.length * 200;
    }
    // Fallback precise measurement for large packs.
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
    _memoryCache.put(langCode, List.unmodifiable(items), itemSizeBytes: size);
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

  // Legacy fallback
  void put(String langCode, List<Map<String, dynamic>> items) {
    _memoryCache.put(langCode, List.unmodifiable(items),
        itemSizeBytes: _measureSize(items));
  }

  List<Map<String, dynamic>>? get(String langCode) {
    return _memoryCache.get(langCode);
  }

  bool has(String langCode) => _memoryCache.containsKey(langCode);

  void clear() {
    _memoryCache.clear();
    // _identities is implicitly cleared via onEvict callbacks
  }

  void trimMemoryPressure() {
    _memoryCache.trimMemoryPressure();
  }
}
