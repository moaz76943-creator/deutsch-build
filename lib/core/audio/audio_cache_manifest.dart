class AudioEntry {
  final String audioKey;
  final String localPath;
  final int fileSizeBytes;
  final int lastVerifiedEpoch;

  const AudioEntry({
    required this.audioKey,
    required this.localPath,
    required this.fileSizeBytes,
    required this.lastVerifiedEpoch,
  });

  bool get isValid => fileSizeBytes > 0 && localPath.isNotEmpty;
}

class AudioCacheManifest {
  final Map<String, AudioEntry> _cache = {};

  void register(AudioEntry entry) {
    if (entry.isValid) {
      _cache[entry.audioKey] = entry;
    }
  }

  AudioEntry? getEntry(String key) => _cache[key];
  bool contains(String key) => _cache.containsKey(key);
  int get totalCachedFiles => _cache.length;
}
