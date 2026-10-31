import 'package:test/test.dart';
import '../../lib/src/content/temporary_pack_cache_cleaner.dart';

void main() {
  group('TemporaryPackCacheCleaner Unit Tests (L092)', () {
    const cleaner = TemporaryPackCacheCleaner(maxArtifactAgeMinutes: 60);

    test('Purges abandoned incomplete downloads and stale temporary files (>60 min)', () {
      final items = [
        const CacheArtifact(path: '/cache/pack.tmp', fileSizeBytes: 5242880, isIncompleteDownload: true, ageMinutes: 10), // 5MB
        const CacheArtifact(path: '/cache/old.bin', fileSizeBytes: 2097152, isIncompleteDownload: false, ageMinutes: 120), // 2MB
        const CacheArtifact(path: '/cache/fresh.bin', fileSizeBytes: 1048576, isIncompleteDownload: false, ageMinutes: 5), // Keep
      ];

      final result = cleaner.purgeTemporaryFiles(items);
      expect(result['purgedCount'], equals(2));
      expect(result['reclaimedMegabytes'], equals(7.0));
      expect(result['isStorageClean'], isTrue);
    });
  });
}
