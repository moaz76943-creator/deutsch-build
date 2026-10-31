import 'package:test/test.dart';
import '../../lib/src/platform/portable_vault_polyglot_engine.dart';

void main() {
  group('PortableVaultPolyglotEngine Unit Tests (N096)', () {
    final engine = PortableVaultPolyglotEngine();

    test('Packs learner data with AES-256-GCM and Argon2id metadata', () {
      final manifest = engine.packVault(cardsCount: 450, audioCount: 120);
      expect(manifest.formatVersion, equals('4.0.0'));
      expect(manifest.encryptionAlgorithm, equals('AES-256-GCM'));
      expect(manifest.kdfAlgorithm, equals('Argon2id'));
      expect(manifest.totalCards, equals(450));
      expect(manifest.totalAudioClips, equals(120));

      final isValid = engine.validateVaultHeader(manifest);
      expect(isValid, isTrue);
    });

    test('Rejects invalid or corrupted vault manifests', () {
      const corrupted = PolyglotVaultManifest(
        formatVersion: '1.0.0',
        encryptionAlgorithm: 'None',
        kdfAlgorithm: 'MD5',
        totalCards: -1,
        totalAudioClips: 0,
        creationEpochSeconds: 0,
      );
      expect(engine.validateVaultHeader(corrupted), isFalse);
    });
  });
}
