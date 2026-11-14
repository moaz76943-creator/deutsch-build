import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/platform/p2p_self_update_engine.dart';

void main() {
  group('P2pSelfUpdateEngine Unit Tests (N092)', () {
    const engine = P2pSelfUpdateEngine(currentVersionCode: 400);

    test('Validates verified newer P2P release manifest', () {
      const manifest = UpdateManifest(
        newVersion: '4.1.0',
        newVersionCode: 410,
        ed25519Signature: 'a4f9b8c7d6e5f4a3b2c1d0e9f8a7b6c5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0a9',
        deltaPatchUrl: 'p2p://polyglot/patches/4.0.0_to_4.1.0.patch',
        patchSizeBytes: 5242880, // 5MB
      );

      final result = engine.checkUpdate(manifest);
      expect(result['hasUpdate'], isTrue);
      expect(result['isSignatureVerified'], isTrue);
      expect(result['targetVersion'], equals('4.1.0'));
      expect(result['patchSizeMb'], equals(5.0));
      expect(result['isSecurityUpdate'], isTrue);
    });

    test('Rejects updates with equal or older version code', () {
      const manifest = UpdateManifest(
        newVersion: '4.0.0',
        newVersionCode: 400,
        ed25519Signature: 'valid_signature_string_that_is_long_enough',
        deltaPatchUrl: '',
        patchSizeBytes: 0,
      );

      final result = engine.checkUpdate(manifest);
      expect(result['hasUpdate'], isFalse);
    });
  });
}
