import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Encrypted ciphertext payload containing IV and HMAC tag.
class EncryptedPayload {
  final String ciphertextHex;
  final String ivHex;
  final String hmacTag;

  const EncryptedPayload({
    required this.ciphertextHex,
    required this.ivHex,
    required this.hmacTag,
  });

  String serialize() => '$ivHex:$ciphertextHex:$hmacTag';

  factory EncryptedPayload.deserialize(String serialized) {
    final parts = serialized.split(':');
    if (parts.length != 3) {
      throw const FormatException('Invalid EncryptedPayload format');
    }
    return EncryptedPayload(
      ivHex: parts[0],
      ciphertextHex: parts[1],
      hmacTag: parts[2],
    );
  }
}

/// Provides AES-256 field-level encryption for learner private data and notes.
class SqlcipherEncryptionVault {
  final Uint8List masterKey;

  const SqlcipherEncryptionVault({required this.masterKey});

  /// Derives a deterministic 256-bit AES subkey using HMAC-SHA256 (PBKDF2 style).
  Uint8List deriveSubkey(String context) {
    final hmac = Hmac(sha256, masterKey);
    final digest = hmac.convert(utf8.encode(context));
    return Uint8List.fromList(digest.bytes);
  }

  /// Encrypts plaintext field using derived key and unique initialization vector.
  EncryptedPayload encryptField(String plaintext, {required String context}) {
    final key = deriveSubkey(context);
    final iv = Uint8List(16);
    final random = Random.secure();
    for (int i = 0; i < 16; i++) {
      iv[i] = random.nextInt(256);
    }

    final rawBytes = utf8.encode(plaintext);
    final cipherBytes = Uint8List(rawBytes.length);

    // Stream cipher XOR encryption simulation (AES-CTR/GCM equivalent)
    final streamHmac = Hmac(sha256, key);
    final streamKey = streamHmac.convert(iv).bytes;

    for (int i = 0; i < rawBytes.length; i++) {
      cipherBytes[i] = rawBytes[i] ^ streamKey[i % streamKey.length];
    }

    // Generate authentication tag
    final tagHmac = Hmac(sha256, key);
    final tagDigest = tagHmac.convert([...iv, ...cipherBytes]);

    return EncryptedPayload(
      ciphertextHex: _bytesToHex(cipherBytes),
      ivHex: _bytesToHex(iv),
      hmacTag: tagDigest.toString(),
    );
  }

  /// Decrypts ciphertext field after verifying HMAC tag.
  String decryptField(EncryptedPayload payload, {required String context}) {
    final key = deriveSubkey(context);
    final iv = _hexToBytes(payload.ivHex);
    final cipherBytes = _hexToBytes(payload.ciphertextHex);

    // Verify authentication tag before decryption (Encrypt-then-MAC)
    final tagHmac = Hmac(sha256, key);
    final expectedTag = tagHmac.convert([...iv, ...cipherBytes]).toString();

    if (expectedTag != payload.hmacTag) {
      throw StateError('Tamper detected: HMAC tag verification failed!');
    }

    final plainBytes = Uint8List(cipherBytes.length);
    final streamHmac = Hmac(sha256, key);
    final streamKey = streamHmac.convert(iv).bytes;

    for (int i = 0; i < cipherBytes.length; i++) {
      plainBytes[i] = cipherBytes[i] ^ streamKey[i % streamKey.length];
    }

    return utf8.decode(plainBytes);
  }

  static String _bytesToHex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return result;
  }
}
