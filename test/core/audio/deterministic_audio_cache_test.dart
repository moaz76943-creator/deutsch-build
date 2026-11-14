import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/core/audio/deterministic_audio_cache.dart';

void main() {
  group('DeterministicAudioCache Tests', () {
    test('Derives deterministic SHA-256 keys accurately', () {
      final key1 = DeterministicAudioCache.deriveKey(
        text: 'Guten Tag',
        languageIso: 'de',
        speed: 1.0,
      );
      final key2 = DeterministicAudioCache.deriveKey(
        text: 'Guten Tag ',
        languageIso: 'de',
        speed: 1.0,
      );

      expect(key1, equals(key2));
      expect(key1.length, equals(64)); // SHA-256 hex length
    });

    test('Caches items and updates hits and misses metrics', () {
      final cache = DeterministicAudioCache(maxMemoryEntries: 3);
      final sample = Uint8List(100);

      const key = 'test_key_01';
      expect(cache.get(key), isNull);
      expect(cache.misses, equals(1));

      cache.put(key, sample);
      final retrieved = cache.get(key);
      expect(retrieved, isNotNull);
      expect(cache.hits, equals(1));
    });

    test('Evicts least recently used entries when capacity is exceeded', () {
      final cache = DeterministicAudioCache(maxMemoryEntries: 2);
      final sample = Uint8List(100);

      cache.put('k1', sample);
      cache.put('k2', sample);

      // Access k1 to make k2 the oldest
      cache.get('k1');

      // Put k3 which should evict k2
      cache.put('k3', sample);

      expect(cache.entriesCount, equals(2));
      expect(cache.get('k1'), isNotNull);
      expect(cache.get('k3'), isNotNull);
      expect(cache.get('k2'), isNull); // Evicted!
    });
  });
}
