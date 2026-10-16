import 'dart:collection';

class _SizedCacheEntry<V> {
  const _SizedCacheEntry(this.value, this.bytes);
  final V value;
  final int bytes;
}

/// Deterministic LRU admission against entry-count and estimated-byte limits.
/// The size estimator runs only on admission: values MUST be immutable while
/// resident so mutation cannot invalidate the accounting contract.
class LruMemoryCache<K, V> {
  LruMemoryCache({
    this.maxCapacity = 200,
    this.maxMemoryBudget,
    this.sizeEstimator,
  }) {
    if (maxCapacity <= 0 ||
        (maxMemoryBudget != null &&
            (maxMemoryBudget! <= 0 || sizeEstimator == null))) {
      throw ArgumentError('Invalid cache capacity, budget, or estimator');
    }
  }

  final int maxCapacity;
  final int? maxMemoryBudget;
  final int Function(K, V)? sizeEstimator;
  final LinkedHashMap<K, _SizedCacheEntry<V>> _cache =
      LinkedHashMap<K, _SizedCacheEntry<V>>();
  int _currentMemory = 0;

  V? get(K key) {
    final entry = _cache.remove(key);
    if (entry == null) return null;
    _cache[key] = entry;
    return entry.value;
  }

  bool put(K key, V value) {
    final bytes = sizeEstimator?.call(key, value) ?? 0;
    if (bytes < 0 || (maxMemoryBudget != null && bytes > maxMemoryBudget!)) {
      return false;
    }
    final old = _cache.remove(key);
    if (old != null) _currentMemory -= old.bytes;
    _cache[key] = _SizedCacheEntry<V>(value, bytes);
    _currentMemory += bytes;
    _trim(maxCapacity, maxMemoryBudget);
    return true;
  }

  void _trim(int targetCapacity, int? targetBudget) {
    while (_cache.isNotEmpty &&
        (_cache.length > targetCapacity ||
            (targetBudget != null && _currentMemory > targetBudget))) {
      _removeOldest();
    }
  }

  void _removeOldest() {
    final oldest = _cache.keys.first;
    _currentMemory -= _cache.remove(oldest)!.bytes;
  }

  bool remove(K key) {
    final removed = _cache.remove(key);
    if (removed == null) return false;
    _currentMemory -= removed.bytes;
    return true;
  }

  void onMemoryPressure() {
    _trim(maxCapacity ~/ 2, maxMemoryBudget == null
        ? null
        : maxMemoryBudget! ~/ 2);
  }

  int get length => _cache.length;
  int get currentMemory => _currentMemory;
  Iterable<K> get keys => _cache.keys;

  bool containsKey(K key) => _cache.containsKey(key);

  void clear() {
    _cache.clear();
    _currentMemory = 0;
  }
}
