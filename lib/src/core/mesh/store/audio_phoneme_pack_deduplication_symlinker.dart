/// Task 1592: Deduplicates common phoneme wave files across packs
class AudioPhonemeDeduplicator {
  final Map<String, String> _symlinkMap = {};
  void linkPhoneme(String hash, String path) => _symlinkMap[hash] = path;
  bool isShared(String hash) => _symlinkMap.containsKey(hash);
}
