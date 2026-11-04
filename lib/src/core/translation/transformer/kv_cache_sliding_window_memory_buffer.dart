/// Task 1724: Key-Value (KV) cache manager with sliding window
class KvCacheManager {
  final Map<int, List<double>> _kvCache = {};
  void pruneOldTokens(int maxTokens) {
    if (_kvCache.length > maxTokens) _kvCache.clear();
  }
}
