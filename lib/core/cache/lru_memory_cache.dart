import 'dart:collection';

class LruMemoryCache<K, V> {
  final int maxCapacity;
  final int? maxMemoryBudget;
  final int Function(K key, V value)? sizeEstimator;

  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();
  int _currentMemory = 0;

  LruMemoryCache({
    this.maxCapacity = 200,
    this.maxMemoryBudget,
    this.sizeEstimator,
  }) : assert(
          maxMemoryBudget == null || sizeEstimator != null,
          'sizeEstimator is required if maxMemoryBudget is provided',
        );

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    final value = _cache.remove(key) as V;
    _cache[key] = value;
    return value;
  }

  bool put(K key, V value) {
    int itemSize = sizeEstimator?.call(key, value) ?? 0;

    // Reject oversized objects without uncontrolled allocation
    if (maxMemoryBudget != null && itemSize > maxMemoryBudget!) {
      return false;
    }

    if (_cache.containsKey(key)) {
      final oldVal = _cache.remove(key) as V;
      _currentMemory -= sizeEstimator?.call(key, oldVal) ?? 0;
    }

    _cache[key] = value;
    _currentMemory += itemSize;

    _trim();

    return true;
  }

  void _trim() {
    while (_cache.isNotEmpty &&
        (_cache.length > maxCapacity ||
            (maxMemoryBudget != null && _currentMemory > maxMemoryBudget!))) {
      final firstKey = _cache.keys.first;
      _removeInternal(firstKey);
    }
  }

  void _removeInternal(K key) {
    if (_cache.containsKey(key)) {
      final val = _cache.remove(key) as V;
      _currentMemory -= sizeEstimator?.call(key, val) ?? 0;
    }
  }

  bool remove(K key) {
    if (_cache.containsKey(key)) {
      _removeInternal(key);
      return true;
    }
    return false;
  }

  int get length => _cache.length;

  int get currentMemory => _currentMemory;

  Iterable<K> get keys => _cache.keys;

  void clear() {
    _cache.clear();
    _currentMemory = 0;
  }

  bool containsKey(K key) => _cache.containsKey(key);

  void onMemoryPressure() {
    // Trim cache by half to simulate low-memory handling
    final targetCapacity = maxCapacity ~/ 2;
    int targetMemory = 0;
    if (maxMemoryBudget != null) {
      targetMemory = maxMemoryBudget! ~/ 2;
    }

    while (_cache.isNotEmpty &&
        (_cache.length > targetCapacity ||
            (maxMemoryBudget != null && _currentMemory > targetMemory))) {
      final firstKey = _cache.keys.first;
      _removeInternal(firstKey);
    }
  }
}
