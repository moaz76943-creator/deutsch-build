/// Task 1195: Zero-latency cache manager for pre-rendered audio frames
class VoicePacketCacheManager {
  final Map<String, List<int>> _cache = {};
  void cachePacket(String key, List<int> pcm) => _cache[key] = pcm;
  bool isCached(String key) => _cache.containsKey(key);
}
