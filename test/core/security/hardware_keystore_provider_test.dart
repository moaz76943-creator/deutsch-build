import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/security/hardware_keystore_provider.dart';

class MockKeyStoreBridge implements AndroidKeyStoreBridge {
  final Set<String> keys = {};
  HardwareSecurityTier activeTier = HardwareSecurityTier.strongBoxHsm;

  @override
  Future<bool> containsKey(String alias) async => keys.contains(alias);

  @override
  Future<bool> generateKey({required String alias, required bool requireStrongBox}) async {
    keys.add(alias);
    return true;
  }

  @override
  Future<Uint8List> encryptWithKey(String alias, Uint8List plaintext) async {
    final cipher = Uint8List(plaintext.length);
    for (int i = 0; i < plaintext.length; i++) {
      cipher[i] = plaintext[i] ^ 0xAA;
    }
    return cipher;
  }

  @override
  Future<Uint8List> decryptWithKey(String alias, Uint8List ciphertext) async {
    final plain = Uint8List(ciphertext.length);
    for (int i = 0; i < ciphertext.length; i++) {
      plain[i] = ciphertext[i] ^ 0xAA;
    }
    return plain;
  }

  @override
  Future<HardwareSecurityTier> queryHardwareTier() async => activeTier;
}

void main() {
  group('HardwareKeyStoreProvider Tests', () {
    late MockKeyStoreBridge bridge;
    late HardwareKeyStoreProvider provider;

    setUp(() {
      bridge = MockKeyStoreBridge();
      provider = HardwareKeyStoreProvider(bridge: bridge);
    });

    test('Initializes master key and detects StrongBox HSM tier', () async {
      final metadata = await provider.initializeMasterKey();

      expect(metadata.keyAlias, equals('polyglot_vault_master_key'));
      expect(metadata.isStrongBoxBacked, isTrue);
      expect(metadata.tier, equals(HardwareSecurityTier.strongBoxHsm));
      expect(provider.isReady, isTrue);
    });

    test('Seals and unseals master cryptographic seed through hardware bridge', () async {
      final rawSeed = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final sealed = await provider.sealMasterSeed(rawSeed);

      expect(sealed, isNot(equals(rawSeed)));

      final unsealed = await provider.unsealMasterSeed(sealed);
      expect(unsealed, equals(rawSeed));
    });
  });
}
