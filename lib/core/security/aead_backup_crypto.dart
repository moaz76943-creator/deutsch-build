import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'secret_memory_zeroizer.dart';

class AeadCryptoException implements Exception {
  final String message;
  const AeadCryptoException(this.message);
  @override
  String toString() => 'AeadCryptoException: $message';
}

class AeadBackupEnvelope {
  final int version;
  final String kdf;
  final int iterations;
  final String saltHex;
  final String ivHex;
  final String ciphertextHex;
  final String authTagHex;
  final String associatedData;

  const AeadBackupEnvelope({
    required this.version,
    required this.kdf,
    required this.iterations,
    required this.saltHex,
    required this.ivHex,
    required this.ciphertextHex,
    required this.authTagHex,
    required this.associatedData,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'kdf': kdf,
    'iterations': iterations,
    'salt': saltHex,
    'iv': ivHex,
    'ciphertext': ciphertextHex,
    'authTag': authTagHex,
    'aad': associatedData,
  };

  factory AeadBackupEnvelope.fromJson(Map<String, dynamic> json) => AeadBackupEnvelope(
    version: json['version'] as int? ?? 1,
    kdf: json['kdf'] as String? ?? 'PBKDF2-HMAC-SHA256',
    iterations: json['iterations'] as int? ?? 10000,
    saltHex: json['salt'] as String,
    ivHex: json['iv'] as String,
    ciphertextHex: json['ciphertext'] as String,
    authTagHex: json['authTag'] as String,
    associatedData: json['aad'] as String? ?? 'deutsch-bilarabi-backup-v1',
  );
}

/// محرك التشفير الموثق للنسخ الاحتياطية بكلمة مرور المتعلم أو PIN (Study 18 - AEAD Encrypted Backups)
/// يطبق PBKDF2 لاشتقاق المفاتيح و AES مع HMAC-SHA256 (Encrypt-then-MAC) لمنع أي تلاعب
class AeadBackupCrypto {
  static const String defaultAad = 'deutsch-bilarabi-backup-v1';
  static const int pbkdf2Iterations = 10000;
  static const int saltLengthBytes = 16;
  static const int ivLengthBytes = 16;
  static const int keyLengthBytes = 32;

  /// تشفير بيانات التقدم بكلمة مرور/PIN مع توثيق تشفيري كامل
  static AeadBackupEnvelope encryptPayload({
    required Uint8List plaintextBytes,
    required String password,
    String associatedData = defaultAad,
  }) {
    if (password.isEmpty) {
      throw const AeadCryptoException('Password cannot be empty for encrypted backup');
    }

    final random = Random.secure();
    final salt = Uint8List(saltLengthBytes);
    final ivBytes = Uint8List(ivLengthBytes);
    for (var i = 0; i < saltLengthBytes; i++) {
      salt[i] = random.nextInt(256);
    }
    for (var i = 0; i < ivLengthBytes; i++) {
      ivBytes[i] = random.nextInt(256);
    }

    // اشتقاق 64 بايت: 32 بايت لمفتاح AES و 32 بايت لمفتاح HMAC
    final derivedKeyBytes = _pbkdf2(
      password: utf8.encode(password),
      salt: salt,
      iterations: pbkdf2Iterations,
      keyLength: 64,
    );

    try {
      final encKeyBytes = derivedKeyBytes.sublist(0, 32);
      final macKeyBytes = derivedKeyBytes.sublist(32, 64);

      final key = enc.Key(encKeyBytes);
      final iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encryptBytes(plaintextBytes, iv: iv);

      // حساب Authentication Tag عبر HMAC-SHA256 على: AAD || Salt || IV || Ciphertext
      final macPayload = BytesBuilder(copy: false);
      macPayload.add(utf8.encode(associatedData));
      macPayload.add(salt);
      macPayload.add(ivBytes);
      macPayload.add(encrypted.bytes);

      final hmac = Hmac(sha256, macKeyBytes);
      final authTag = hmac.convert(macPayload.toBytes()).bytes;

      return AeadBackupEnvelope(
        version: 1,
        kdf: 'PBKDF2-HMAC-SHA256',
        iterations: pbkdf2Iterations,
        saltHex: _bytesToHex(salt),
        ivHex: _bytesToHex(ivBytes),
        ciphertextHex: _bytesToHex(encrypted.bytes),
        authTagHex: _bytesToHex(Uint8List.fromList(authTag)),
        associatedData: associatedData,
      );
    } finally {
      SecretMemoryZeroizer.zeroize(derivedKeyBytes);
    }
  }

  /// فك تشفير والتحقق من سلامة النسخة الاحتياطية المشفرة
  static Uint8List decryptEnvelope({
    required AeadBackupEnvelope envelope,
    required String password,
  }) {
    final salt = _hexToBytes(envelope.saltHex);
    final ivBytes = _hexToBytes(envelope.ivHex);
    final ciphertext = _hexToBytes(envelope.ciphertextHex);
    final expectedAuthTag = _hexToBytes(envelope.authTagHex);

    final derivedKeyBytes = _pbkdf2(
      password: utf8.encode(password),
      salt: salt,
      iterations: envelope.iterations,
      keyLength: 64,
    );

    try {
      final encKeyBytes = derivedKeyBytes.sublist(0, 32);
      final macKeyBytes = derivedKeyBytes.sublist(32, 64);

      // 1. التحقق من سلامة التوثيق (MAC Verification) قبل محاولة فك التشفير
      final macPayload = BytesBuilder(copy: false);
      macPayload.add(utf8.encode(envelope.associatedData));
      macPayload.add(salt);
      macPayload.add(ivBytes);
      macPayload.add(ciphertext);

      final hmac = Hmac(sha256, macKeyBytes);
      final calculatedTag = hmac.convert(macPayload.toBytes()).bytes;

      if (!_constantTimeEquals(calculatedTag, expectedAuthTag)) {
        throw const AeadCryptoException(
          'Authentication failed: incorrect password or corrupted backup ciphertext',
        );
      }

      // 2. فك التشفير بعد التأكد من صحة التوثيق 100%
      final key = enc.Key(encKeyBytes);
      final iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decryptBytes(enc.Encrypted(ciphertext), iv: iv);

      return Uint8List.fromList(decrypted);
    } finally {
      SecretMemoryZeroizer.zeroize(derivedKeyBytes);
    }
  }

  static Uint8List _pbkdf2({
    required List<int> password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  }) {
    final hmac = Hmac(sha256, password);
    final blocksNeeded = (keyLength + 31) ~/ 32;
    final result = BytesBuilder(copy: false);

    for (var blockIndex = 1; blockIndex <= blocksNeeded; blockIndex++) {
      // U1 = HMAC(Password, Salt || INT_32_BE(blockIndex))
      final saltBlock = Uint8List(salt.length + 4);
      saltBlock.setRange(0, salt.length, salt);
      final bd = ByteData.sublistView(saltBlock, salt.length, salt.length + 4);
      bd.setUint32(0, blockIndex, Endian.big);

      var u = hmac.convert(saltBlock).bytes;
      final blockXor = Uint8List.fromList(u);

      for (var iter = 1; iter < iterations; iter++) {
        u = hmac.convert(u).bytes;
        for (var k = 0; k < blockXor.length; k++) {
          blockXor[k] ^= u[k];
        }
      }

      result.add(blockXor);
    }

    final full = result.takeBytes();
    return full.sublist(0, keyLength);
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  static String _bytesToHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  static Uint8List _hexToBytes(String hex) {
    final len = hex.length;
    final bytes = Uint8List(len ~/ 2);
    for (var i = 0; i < len; i += 2) {
      bytes[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return bytes;
  }
}
