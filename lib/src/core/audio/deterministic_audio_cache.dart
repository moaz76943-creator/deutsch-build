import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Entry stored in the audio memory cache.
class AudioCacheEntry {
  final String key;
  final Uint8List pcmBytes;
  DateTime lastAccessedAt;

  AudioCacheEntry({
    required this.key,
    required this.pcmBytes,
    required this.lastAccessedAt,
  });

  int get sizeInBytes => pcmBytes.lengthInBytes;
}

/// Deterministic in-memory and disk LRU cache for synthesized speech.
class DeterministicAudioCache {
  final int maxMemoryEntries;
  final int maxMemoryBytes;

  final Map<String, AudioCacheEntry> _cache = {};
  int _currentMemoryBytes = 0;
  int _hits = 0;
  int _misses = 0;

  DeterministicAudioCache({
    this.maxMemoryEntries = 64,
    this.maxMemoryBytes = 16 * 1024 * 1024, // 16 MB
  });

  int get entriesCount => _cache.length;
  int get currentMemoryBytes => _currentMemoryBytes;
  int get hits => _hits;
  int get misses => _misses;

  /// Generates a deterministic SHA-256 cache key.
  static String deriveKey({
    required String text,
    required String languageIso,
    double speed = 1.0,
    String voiceId = 'default',
  }) {
    final raw = '${languageIso.toLowerCase()}:$voiceId:${speed.toStringAsFixed(2)}:${text.trim().toLowerCase()}';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  /// Retrieves PCM audio bytes from cache if present, updating LRU access time.
  Uint8List? get(String key) {
    final entry = _cache[key];
    if (entry != null) {
      entry.lastAccessedAt = DateTime.now();
      _hits++;
      return entry.pcmBytes;
    }
    _misses++;
    return null;
  }

  /// Inserts PCM audio buffer, evicting oldest entries if limits are exceeded.
  void put(String key, Uint8List pcmBytes) {
    if (_cache.containsKey(key)) {
      final existing = _cache[key]!;
      _currentMemoryBytes -= existing.sizeInBytes;
    }

    final entry = AudioCacheEntry(
      key: key,
      pcmBytes: pcmBytes,
      lastAccessedAt: DateTime.now(),
    );

    _cache[key] = entry;
    _currentMemoryBytes += entry.sizeInBytes;

    _enforceLruLimits();
  }

  /// Evicts least recently used entries until within constraints.
  void _enforceLruLimits() {
    if (_cache.length <= maxMemoryEntries && _currentMemoryBytes <= maxMemoryBytes) {
      return;
    }

    // Sort entries by lastAccessedAt ascending (oldest first)
    final sortedEntries = _cache.values.toList()
      ..sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));

    for (final oldest in sortedEntries) {
      if (_cache.length <= maxMemoryEntries && _currentMemoryBytes <= maxMemoryBytes) {
        break;
      }
      _cache.remove(oldest.key);
      _currentMemoryBytes -= oldest.sizeInBytes;
    }
  }

  /// Purges all memory cache immediately on low-RAM alerts.
  void clear() {
    _cache.clear();
    _currentMemoryBytes = 0;
  }
}
