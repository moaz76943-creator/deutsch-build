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

  bool get isValid =>
      audioKey.isNotEmpty && fileSizeBytes > 0 && localPath.isNotEmpty;
}

/// Bounded metadata index for temporary/local audio entries.
///
/// This class never uploads, downloads, or opens audio. It only limits the
/// in-memory manifest and the amount of cache data represented by it.
class AudioCacheManifest {
  AudioCacheManifest({
    this.maxEntries = 256,
    this.maxBytes = 64 * 1024 * 1024,
  })  : assert(maxEntries > 0),
        assert(maxBytes > 0);

  final int maxEntries;
  final int maxBytes;
  final Map<String, AudioEntry> _cache = <String, AudioEntry>{};
  int _totalBytes = 0;

  void register(AudioEntry entry) {
    if (!entry.isValid || entry.fileSizeBytes > maxBytes) return;

    final replaced = _cache.remove(entry.audioKey);
    if (replaced != null) _totalBytes -= replaced.fileSizeBytes;

    _cache[entry.audioKey] = entry;
    _totalBytes += entry.fileSizeBytes;
    _trim();
  }

  void _trim() {
    while (_cache.length > maxEntries || _totalBytes > maxBytes) {
      if (_cache.isEmpty) break;
      AudioEntry? oldest;
      for (final candidate in _cache.values) {
        if (oldest == null ||
            candidate.lastVerifiedEpoch < oldest.lastVerifiedEpoch) {
          oldest = candidate;
        }
      }
      if (oldest == null) break;
      _cache.remove(oldest.audioKey);
      _totalBytes -= oldest.fileSizeBytes;
    }
  }

  AudioEntry? getEntry(String key) => _cache[key];

  bool contains(String key) => _cache.containsKey(key);

  bool remove(String key) {
    final removed = _cache.remove(key);
    if (removed == null) return false;
    _totalBytes -= removed.fileSizeBytes;
    return true;
  }

  void clear() {
    _cache.clear();
    _totalBytes = 0;
  }

  int get totalCachedFiles => _cache.length;

  int get totalCachedBytes => _totalBytes;
}
