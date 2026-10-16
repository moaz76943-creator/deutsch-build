import 'dart:collection';

class _CacheEntry<V> {
  final V value;
  final int size;

  _CacheEntry(this.value, this.size);
}

class LruMemoryCache<K, V> {
  final int maxCapacity;
  final int maxMemoryBytes;
  final int Function(K key, V value)? sizeEstimator;

  final LinkedHashMap<K, _CacheEntry<V>> _cache = LinkedHashMap<K, _CacheEntry<V>>();
  int _currentMemoryBytes = 0;

  LruMemoryCache({
    this.maxCapacity = 200,
    this.maxMemoryBytes = 10 * 1024 * 1024, // Default 10MB
    this.sizeEstimator,
  });

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    final entry = _cache.remove(key) as _CacheEntry<V>;
    _cache[key] = entry;
    return entry.value;
  }

  bool put(K key, V value) {
    int entrySize = 0;
    if (sizeEstimator != null) {
      entrySize = sizeEstimator!(key, value);
      if (entrySize > maxMemoryBytes) {
        return false; // Reject explicitly oversized objects
      }
    }

    if (_cache.containsKey(key)) {
      _remove(key);
    }

    // Evict based on count and memory
    while (_cache.isNotEmpty && (_cache.length >= maxCapacity || _currentMemoryBytes + entrySize > maxMemoryBytes)) {
      final firstKey = _cache.keys.first;
      _remove(firstKey);
    }

    _cache[key] = _CacheEntry<V>(value, entrySize);
    _currentMemoryBytes += entrySize;
    return true;
  }

  V? remove(K key) {
     return _remove(key);
  }

  V? _remove(K key) {
     if (!_cache.containsKey(key)) return null;
     final entry = _cache.remove(key) as _CacheEntry<V>;
     _currentMemoryBytes -= entry.size;
     return entry.value;
  }

  void trim(int targetMemoryBytes) {
      while (_cache.isNotEmpty && _currentMemoryBytes > targetMemoryBytes) {
          final firstKey = _cache.keys.first;
          _remove(firstKey);
      }
  }

  void onMemoryPressure() {
      // Trim to 50% of maxMemoryBytes when under memory pressure
      trim(maxMemoryBytes ~/ 2);
  }

  int get length => _cache.length;
  int get currentMemoryBytes => _currentMemoryBytes;

  Iterable<K> get keys => _cache.keys;

  void clear() {
      _cache.clear();
      _currentMemoryBytes = 0;
  }

  bool containsKey(K key) => _cache.containsKey(key);
}