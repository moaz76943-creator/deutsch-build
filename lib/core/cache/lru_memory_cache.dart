import 'dart:collection';

/// Deterministically bounded by entry count and, when configured, estimated
/// retained bytes. Stored entry sizes never depend on later estimator changes.
class LruMemoryCache<K, V> {
  final int maxCapacity;
  final int? maxMemoryBudget;
  final int Function(K, V)? sizeEstimator;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();
  final Map<K, int> _sizes = {};
  int _currentMemory = 0;

  LruMemoryCache({
    this.maxCapacity = 200,
    this.maxMemoryBudget,
    this.sizeEstimator,
  }) {
    if (maxCapacity <= 0 || (maxMemoryBudget != null &&
        (maxMemoryBudget! <= 0 || sizeEstimator == null))) {
      throw ArgumentError('A positive capacity and valid byte estimator are required');
    }
  }

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    final value = _cache.remove(key) as V;
    _cache[key] = value;
    return value;
  }

  bool put(K key, V value) {
    final size = sizeEstimator?.call(key, value) ?? 1;
    if (size < 0) throw ArgumentError('Negative cache size');
    if (maxMemoryBudget != null && size > maxMemoryBudget!) return false;
    remove(key);
    _cache[key] = value;
    _sizes[key] = size;
    _currentMemory += size;
    _trim(maxCapacity, maxMemoryBudget);
    return true;
  }

  void _trim(int capacity, int? budget) {
    while (_cache.isNotEmpty &&
        (_cache.length > capacity ||
        (budget != null && _currentMemory > budget))) {
      remove(_cache.keys.first);
    }
  }

  bool remove(K key) {
    if (!_cache.containsKey(key)) return false;
    _cache.remove(key);
    _currentMemory -= _sizes.remove(key) ?? 0;
    return true;
  }

  int get length => _cache.length;
  int get currentMemory => _currentMemory;
  Iterable<K> get keys => List<K>.unmodifiable(_cache.keys);
  bool containsKey(K key) => _cache.containsKey(key);

  void clear() {
    _cache.clear();
    _sizes.clear();
    _currentMemory = 0;
  }

  void onMemoryPressure() {
    _trim(maxCapacity ~/ 2, maxMemoryBudget == null
        ? null : maxMemoryBudget! ~/ 2);
  }
}
