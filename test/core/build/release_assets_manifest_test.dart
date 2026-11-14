import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/build/release_assets_manifest.dart';

void main() {
  group('ReleaseAssetsManifest Tests', () {
    test('Validates complete release assets configuration', () {
      const manifest = ReleaseAssetsManifest(
        totalProfilesCount: 12,
        hasEmbeddedDatabase: true,
        hasAudioModels: true,
        isProGuardConfigured: true,
      );

      expect(manifest.isReadyForPackaging, isTrue);
      expect(manifest.toJson()['totalProfilesCount'], equals(12));
    });
  });
}
