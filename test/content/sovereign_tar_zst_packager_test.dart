import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/sovereign_tar_zst_packager.dart';

void main() {
  group('SovereignTarZstPackager Unit Tests (L095)', () {
    final packager = SovereignTarZstPackager();

    test('Creates valid .tar.zst archive manifest with compressed byte ratio', () {
      const sha = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
      final manifest = packager.createBundleManifest(
        packId: 'polyglot_de_ar_complete',
        locale: 'ar',
        fileCount: 12,
        rawBytes: 100000000, // 100MB
        checksum: sha,
      );

      expect(manifest.bundleId, equals('polyglot_de_ar_complete.tar.zst'));
      expect(manifest.compressedSizeBytes, equals(35000000)); // 35MB
      expect(packager.verifyBundle(manifest), isTrue);
    });

    test('Rejects bundles with prohibited language code', () {
      final tainted = packager.createBundleManifest(
        packId: 'tainted',
        locale: 'he', // Prohibited
        fileCount: 5,
        rawBytes: 1000,
        checksum: '1234567890123456789012345678901234567890123456789012345678901234',
      );
      expect(packager.verifyBundle(tainted), isFalse);
    });
  });
}
