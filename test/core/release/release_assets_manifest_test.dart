import 'package:test/test.dart';
import 'package:deutsch_build/src/core/release/release_assets_manifest.dart';

void main() {
  test('Validates complete release assets configuration', () {
    const manifest = ReleaseAssetsManifest(
      totalProfilesCount: 12,
      hasEmbeddedDatabase: true,
      hasAudioModels: true,
      isProGuardConfigured: true,
    );
    expect(manifest.isReadyForPackaging, isTrue);
  });
}
