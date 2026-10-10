import 'dart:collection';

class LruMemoryCache<K, V> {
  final int maxCapacity;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  LruMemoryCache({this.maxCapacity = 200});

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    final value = _cache.remove(key) as V;
    _cache[key] = value;
    return value;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxCapacity) {
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[key] = value;
  }

  int get length => _cache.length;

  void clear() => _cache.clear();

  bool containsKey(K key) => _cache.containsKey(key);
}