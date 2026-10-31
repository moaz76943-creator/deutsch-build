import 'dart:collection';
import 'dart:typed_data';

/// Memory-only LRU cache for lightweight vocabulary images.
final class CacheManager {
  CacheManager({
    this.maxEntries = 48,
    this.maxBytes = 2 * 1024 * 1024,
  })  : assert(maxEntries > 0),
        assert(maxBytes > 0);

  final int maxEntries;
  final int maxBytes;
  final LinkedHashMap<String, Uint8List> _entries = LinkedHashMap();

  int _currentBytes = 0;

  int get length => _entries.length;
  int get currentBytes => _currentBytes;
  Iterable<String> get keys => List<String>.unmodifiable(_entries.keys);

  Uint8List? get(String key) {
    final value = _entries.remove(key);
    if (value == null) return null;
    _entries[key] = value;
    return value;
  }

  void put(String key, Uint8List bytes) {
    if (key.isEmpty || bytes.isEmpty) return;
    final previous = _entries.remove(key);
    if (previous != null) {
      _currentBytes -= previous.lengthInBytes;
    }

    if (bytes.lengthInBytes > maxBytes) {
      return;
    }

    _entries[key] = bytes;
    _currentBytes += bytes.lengthInBytes;
    _evictToBudget();
  }

  bool contains(String key) => _entries.containsKey(key);

  void remove(String key) {
    final removed = _entries.remove(key);
    if (removed != null) {
      _currentBytes -= removed.lengthInBytes;
    }
  }

  void clear() {
    _entries.clear();
    _currentBytes = 0;
  }

  void _evictToBudget() {
    while (_entries.length > maxEntries || _currentBytes > maxBytes) {
      final oldest = _entries.keys.first;
      final removed = _entries.remove(oldest);
      if (removed != null) {
        _currentBytes -= removed.lengthInBytes;
      }
    }
  }
}
