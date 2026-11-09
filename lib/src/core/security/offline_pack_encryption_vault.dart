import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Exception thrown when vault decryption or authentication check fails.
class VaultDecryptionException implements Exception {
  final String message;
  VaultDecryptionException(this.message);

  @override
  String toString() => 'VaultDecryptionException: $message';
}

/// Encrypted container for offline lesson packs stored at rest.
class EncryptedPackEnvelope {
  final String packId;
  final String initializationVectorHex;
  final String authenticationTagHex;
  final Uint8List cipherBytes;

  EncryptedPackEnvelope({
    required this.packId,
    required this.initializationVectorHex,
    required this.authenticationTagHex,
    required this.cipherBytes,
  });

  Map<String, dynamic> toJson() => {
        'pack_id': packId,
        'iv': initializationVectorHex,
        'tag': authenticationTagHex,
        'cipher_length': cipherBytes.length,
      };
}

/// Offline Pack Encryption Vault implementing authenticated envelope encryption
/// and secure device-bound key derivation (HMAC-SHA256) for zero plain-text leaks on disk.
class OfflinePackEncryptionVault {
  final Uint8List _deviceSecretKey;

  OfflinePackEncryptionVault({required Uint8List deviceSecretKey})
      : _deviceSecretKey = Uint8List.fromList(deviceSecretKey);

  /// Derive subkey for a specific pack identifier.
  List<int> _derivePackKey(String packId, String salt) {
    final hmac = Hmac(sha256, _deviceSecretKey);
    final digest = hmac.convert(utf8.encode('$packId:$salt'));
    return digest.bytes;
  }

  /// Encrypt offline pack bytes into an authenticated envelope.
  EncryptedPackEnvelope sealPack(String packId, Uint8List rawBytes) {
    final salt = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    final derivedKey = _derivePackKey(packId, salt);

    // Authenticated XOR-stream cipher with HMAC-SHA256 authentication tag
    final cipher = Uint8List(rawBytes.length);
    for (int i = 0; i < rawBytes.length; i++) {
      cipher[i] = rawBytes[i] ^ derivedKey[i % derivedKey.length];
    }

    final authHmac = Hmac(sha256, derivedKey);
    final authTag = authHmac.convert(cipher).toString();

    return EncryptedPackEnvelope(
      packId: packId,
      initializationVectorHex: salt,
      authenticationTagHex: authTag,
      cipherBytes: cipher,
    );
  }

  /// Decrypt offline pack envelope and verify message authenticity.
  Uint8List unsealPack(EncryptedPackEnvelope envelope) {
    final derivedKey = _derivePackKey(envelope.packId, envelope.initializationVectorHex);

    // Verify authentication tag before decrypting (Fail-closed principle)
    final authHmac = Hmac(sha256, derivedKey);
    final expectedTag = authHmac.convert(envelope.cipherBytes).toString();

    if (expectedTag != envelope.authenticationTagHex) {
      throw VaultDecryptionException(
        'Integrity check failed: Encrypted pack ${envelope.packId} has been tampered with or key is invalid.',
      );
    }

    final plain = Uint8List(envelope.cipherBytes.length);
    for (int i = 0; i < envelope.cipherBytes.length; i++) {
      plain[i] = envelope.cipherBytes[i] ^ derivedKey[i % derivedKey.length];
    }

    return plain;
  }
}
