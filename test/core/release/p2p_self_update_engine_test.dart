import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/release/p2p_self_update_engine.dart';

void main() {
  group('P2pSelfUpdateEngine Tests', () {
    const engine = P2pSelfUpdateEngine(currentInstalledVersionCode: 300);

    const validManifest = ReleasePackageManifest(
      versionCode: 301,
      versionName: '3.0.1',
      localizedReleaseNotes: {
        'ar': 'إضافة ميزات الذكاء الاصطناعي الصوتي ومحاكي المقابلات.',
        'de': 'Erweiterung der Sprach-KI und Vorstellungsgesprächs-Szenarien.',
        'en': 'Added voice AI dialogue simulation and interview modules.',
      },
      sha256Checksum: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
      developerEd25519Signature: 'SIG_ED25519_VALID_POLYGLOT_ROOT_SECURE',
      fileSizeBytes: 24500000,
    );

    test('Approves valid newer update with correct SHA256 and Ed25519 signature', () {
      final isValid = engine.validateUpdatePackage(
        validManifest,
        'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
      );

      expect(isValid, isTrue);
    });

    test('Rejects update when binary SHA256 does not match manifest checksum', () {
      final isValid = engine.validateUpdatePackage(validManifest, 'mismatched_corrupt_hash');
      expect(isValid, isFalse);
    });

    test('Rejects downgrade or identical version code update', () {
      const olderManifest = ReleasePackageManifest(
        versionCode: 299,
        versionName: '2.9.9',
        localizedReleaseNotes: {},
        sha256Checksum: 'abc',
        developerEd25519Signature: 'SIG_ED25519_VALID_POLYGLOT_ROOT_SECURE',
        fileSizeBytes: 1000,
      );

      final isValid = engine.validateUpdatePackage(olderManifest, 'abc');
      expect(isValid, isFalse);
    });

    test('Resolves localized changelog correctly', () {
      final arNotes = engine.getLocalizedChangelog(validManifest, 'ar');
      final deNotes = engine.getLocalizedChangelog(validManifest, 'de');

      expect(arNotes, contains('إضافة ميزات الذكاء الاصطناعي'));
      expect(deNotes, contains('Erweiterung der Sprach-KI'));
    });
  });
}
