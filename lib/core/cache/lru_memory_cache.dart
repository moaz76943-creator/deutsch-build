import 'dart:collection';

class LruMemoryCache<K, V> {
  final int maxCapacity;
  final int? maxMemoryBytes;
  final void Function(K)? onEvict;
  final int Function(K, V)? sizeEstimator;

  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();
  final Map<K, int> _sizes = {};

  int _currentMemoryBytes = 0;

  LruMemoryCache({
    this.maxCapacity = 200,
    this.maxMemoryBytes,
    this.onEvict,
    this.sizeEstimator,
  });

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    final value = _cache.remove(key) as V;
    _cache[key] = value;
    return value;
  }

  bool put(K key, V value, {int itemSizeBytes = 0}) {
    int calculatedSize = itemSizeBytes;
    if (sizeEstimator != null) {
      calculatedSize = sizeEstimator!(key, value);
    }

    if (maxMemoryBytes != null && calculatedSize > maxMemoryBytes!) {
      return false; // Reject oversized item without caching
    }

    if (_cache.containsKey(key)) {
      _currentMemoryBytes -= _sizes[key] ?? 0;
      _cache.remove(key);
    }

    _cache[key] = value;
    _sizes[key] = calculatedSize;
    _currentMemoryBytes += calculatedSize;

    _evictToFit();
    return true;
  }

  void remove(K key) {
    if (_cache.containsKey(key)) {
      _currentMemoryBytes -= _sizes[key] ?? 0;
      _cache.remove(key);
      _sizes.remove(key);
    }
  }

  void _evictToFit() {
    while (_cache.isNotEmpty &&
        (_cache.length > maxCapacity ||
            (maxMemoryBytes != null &&
                _currentMemoryBytes > maxMemoryBytes!))) {
      final firstKey = _cache.keys.first;
      _currentMemoryBytes -= _sizes[firstKey] ?? 0;
      _cache.remove(firstKey);
      _sizes.remove(firstKey);
      if (onEvict != null) {
        onEvict!(firstKey);
      }
    }
  }

  void trimMemoryPressure() {
    if (_cache.isEmpty) return;

    final targetCapacity = maxCapacity ~/ 2;
    int targetMemory = maxMemoryBytes != null ? maxMemoryBytes! ~/ 2 : 0;

    while (_cache.isNotEmpty &&
        (_cache.length > targetCapacity ||
            (maxMemoryBytes != null && _currentMemoryBytes > targetMemory))) {
      final firstKey = _cache.keys.first;
      _currentMemoryBytes -= _sizes[firstKey] ?? 0;
      _cache.remove(firstKey);
      _sizes.remove(firstKey);
      if (onEvict != null) {
        onEvict!(firstKey);
      }
    }
  }

  void onMemoryPressure() {
     trimMemoryPressure();
  }

  int get length => _cache.length;
  int get currentMemoryBytes => _currentMemoryBytes;

  Iterable<K> get keys => _cache.keys;

  void clear() {
    final keysList = List<K>.from(_cache.keys);
    _cache.clear();
    _sizes.clear();
    _currentMemoryBytes = 0;
    if (onEvict != null) {
      for (final key in keysList) {
        onEvict!(key);
      }
    }
  }

  bool containsKey(K key) => _cache.containsKey(key);
}
