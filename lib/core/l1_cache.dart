import 'cache/lru_memory_cache.dart';

class CacheIdentity {
  final String language;
  final String direction;
  final int packVersion;

  const CacheIdentity({
    required this.language,
    this.direction = 'legacy',
    this.packVersion = 0,
  });

  @override
  bool operator ==(Object other) => other is CacheIdentity &&
      language == other.language && direction == other.direction &&
      packVersion == other.packVersion;

  @override
  int get hashCode => Object.hash(language, direction, packVersion);
}

class L1VocabularyCache {
  static final L1VocabularyCache _instance = L1VocabularyCache._internal();
  factory L1VocabularyCache() => _instance;

  static const int maxCacheBytes = 5 * 1024 * 1024;
  static const int maxIdentities = 50;
  late final LruMemoryCache<CacheIdentity, List<Map<String, dynamic>>> _cache;

  L1VocabularyCache._internal() {
    _cache = LruMemoryCache(
      maxCapacity: maxIdentities,
      maxMemoryBudget: maxCacheBytes,
      sizeEstimator: (key, data) => _sizeOf(data),
    );
  }

  // A conservative, bounded estimate for the owned immutable snapshot.
  // Rejected nested structures cannot hide additional retained references.
  static int _sizeOf(Object? value, [int depth = 0]) {
    if (depth > 12) throw ArgumentError('Cache nesting too deep');
    if (value == null || value is bool || value is num) return 16;
    if (value is String) return 48 + value.length * 2;
    if (value is List) {
      if (value.length > 10000) throw ArgumentError('Cache list too large');
      var size = 64;
      for (final item in value) {
        size += _sizeOf(item, depth + 1);
        if (size > maxCacheBytes) return size;
      }
      return size;
    }
    if (value is Map) {
      if (value.length > 10000) throw ArgumentError('Cache map too large');
      var size = 96;
      for (final entry in value.entries) {
        size += _sizeOf(entry.key, depth + 1);
        size += _sizeOf(entry.value, depth + 1);
        if (size > maxCacheBytes) return size;
      }
      return size;
    }
    throw ArgumentError('Cache payload must contain JSON-like values');
  }

  static Object? _freeze(Object? value, [int depth = 0]) {
    if (depth > 12) throw ArgumentError('Cache nesting too deep');
    if (value is List) {
      if (value.length > 10000) throw ArgumentError('Cache list too large');
      return List<dynamic>.unmodifiable(
        value.map((element) => _freeze(element, depth + 1)),
      );
    }
    if (value is Map) {
      if (value.length > 10000) throw ArgumentError('Cache map too large');
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        if (entry.key is! String) throw ArgumentError('Cache keys must be strings');
        result[entry.key as String] = _freeze(entry.value, depth + 1);
      }
      return Map<String, dynamic>.unmodifiable(result);
    }
    if (value == null || value is bool || value is num || value is String) {
      return value;
    }
    throw ArgumentError('Unsupported cache payload');
  }

  bool put(String langCode, List<Map<String, dynamic>> items, {
    String direction = 'legacy', int packVersion = 0,
  }) {
    if (langCode.isEmpty || direction.isEmpty || packVersion < 0) {
      throw ArgumentError('Invalid cache identity');
    }
    // Reject oversized source collections before allocating an owned copy.
    if (_sizeOf(items) > maxCacheBytes) return false;
    final immutable = List<Map<String, dynamic>>.unmodifiable(
      items.map((row) => _freeze(row) as Map<String, dynamic>),
    );
    return _cache.put(
      CacheIdentity(language: langCode, direction: direction,
          packVersion: packVersion),
      immutable,
    );
  }

  List<Map<String, dynamic>>? get(String langCode, {
    String direction = 'legacy', int packVersion = 0,
  }) => _cache.get(CacheIdentity(
    language: langCode, direction: direction, packVersion: packVersion,
  ));

  bool has(String langCode, {
    String direction = 'legacy', int packVersion = 0,
  }) => _cache.containsKey(CacheIdentity(
    language: langCode, direction: direction, packVersion: packVersion,
  ));

  void invalidateStale(String langCode, String direction, int version) {
    final obsolete = _cache.keys.where((key) => key.language == langCode &&
        key.direction == direction && key.packVersion != version).toList();
    for (final key in obsolete) {
      _cache.remove(key);
    }
  }

  int get estimatedMemoryBytes => _cache.currentMemory;
  int get identityCount => _cache.length;
  void onMemoryPressure() => _cache.onMemoryPressure();
  void clear() => _cache.clear();
}
