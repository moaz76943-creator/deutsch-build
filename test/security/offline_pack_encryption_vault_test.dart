import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/core/security/offline_pack_encryption_vault.dart';

void main() {
  group('OfflinePackEncryptionVault - Security & Data Integrity', () {
    late OfflinePackEncryptionVault vault;
    final deviceKey = Uint8List.fromList(List.generate(32, (i) => i));

    setUp(() {
      vault = OfflinePackEncryptionVault(deviceSecretKey: deviceKey);
    });

    test('seal and unseal round-trip preserves data', () {
      final original = Uint8List.fromList([1, 2, 3, 4, 5, 42, 100]);
      final envelope = vault.sealPack('de-core-v1', original);
      final decrypted = vault.unsealPack(envelope);
      expect(decrypted, original);
      expect(envelope.packId, 'de-core-v1');
      expect(envelope.cipherBytes, isNot(original));
    });

    test('tampered ciphertext fails authentication', () {
      final original = Uint8List.fromList([10, 20, 30]);
      final envelope = vault.sealPack('test-pack', original);
      final tampered = EncryptedPackEnvelope(
        packId: envelope.packId,
        initializationVectorHex: envelope.initializationVectorHex,
        authenticationTagHex: envelope.authenticationTagHex,
        cipherBytes: Uint8List.fromList(envelope.cipherBytes.map((b) => b ^ 1).toList()),
      );
      expect(
        () => vault.unsealPack(tampered),
        throwsA(isA<VaultDecryptionException>()),
      );
    });

    test('wrong key or salt fails', () {
      final original = Uint8List.fromList([7, 8, 9]);
      final envelope = vault.sealPack('sensitive', original);
      final wrongVault = OfflinePackEncryptionVault(
        deviceSecretKey: Uint8List.fromList(List.generate(32, (i) => 255 - i)),
      );
      expect(
        () => wrongVault.unsealPack(envelope),
        throwsA(isA<VaultDecryptionException>()),
      );
    });

    test('empty payload is handled', () {
      final empty = Uint8List(0);
      final envelope = vault.sealPack('empty', empty);
      final decrypted = vault.unsealPack(envelope);
      expect(decrypted, empty);
    });
  });
}
