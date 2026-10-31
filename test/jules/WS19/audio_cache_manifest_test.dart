import 'package:deutsch_bilarabi/core/audio/audio_cache_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

AudioEntry entry(String key, int bytes, int epoch) => AudioEntry(
      audioKey: key,
      localPath: '/tmp/' + key + '.opus',
      fileSizeBytes: bytes,
      lastVerifiedEpoch: epoch,
    );

void main() {
  test('cache manifest evicts oldest entry when count is exceeded', () {
    final manifest = AudioCacheManifest(maxEntries: 2, maxBytes: 100);

    manifest.register(entry('old', 10, 1));
    manifest.register(entry('newer', 10, 2));
    manifest.register(entry('newest', 10, 3));

    expect(manifest.contains('old'), isFalse);
    expect(manifest.contains('newer'), isTrue);
    expect(manifest.contains('newest'), isTrue);
    expect(manifest.totalCachedFiles, 2);
  });

  test('cache manifest stays within represented byte budget', () {
    final manifest = AudioCacheManifest(maxEntries: 10, maxBytes: 20);

    manifest.register(entry('old', 12, 1));
    manifest.register(entry('new', 12, 2));

    expect(manifest.contains('old'), isFalse);
    expect(manifest.contains('new'), isTrue);
    expect(manifest.totalCachedBytes, 12);
  });

  test('single oversized or invalid entry is rejected', () {
    final manifest = AudioCacheManifest(maxEntries: 2, maxBytes: 20);

    manifest.register(entry('too-big', 21, 1));
    manifest.register(const AudioEntry(
      audioKey: '',
      localPath: '/tmp/invalid.opus',
      fileSizeBytes: 1,
      lastVerifiedEpoch: 2,
    ));

    expect(manifest.totalCachedFiles, 0);
    expect(manifest.totalCachedBytes, 0);
  });

  test('replacement keeps byte accounting exact', () {
    final manifest = AudioCacheManifest(maxEntries: 2, maxBytes: 20);

    manifest.register(entry('same', 15, 1));
    manifest.register(entry('same', 5, 2));

    expect(manifest.totalCachedFiles, 1);
    expect(manifest.totalCachedBytes, 5);
  });
}
