import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:synchronized/synchronized.dart';

abstract class VaultCipher {
  Future<String> encrypt(String plaintext, String id);
  Future<String> decrypt(String ciphertext, String id);
}

class AndroidKeystoreVaultCipher implements VaultCipher {
  static const MethodChannel _channel = MethodChannel('com.deutschbilarabi.app/vault');

  @override
  Future<String> encrypt(String plaintext, String id) async {
    final String? result = await _channel.invokeMethod('encrypt', {
      'data': plaintext,
      'id': id,
    });
    if (result == null) throw Exception('Encryption failed');
    return result;
  }

  @override
  Future<String> decrypt(String ciphertext, String id) async {
    final String? result = await _channel.invokeMethod('decrypt', {
      'data': ciphertext,
      'id': id,
    });
    if (result == null) throw Exception('Decryption failed');
    return result;
  }
}

class VaultException implements Exception {
  final String message;
  VaultException(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

class KeyUnavailableException extends VaultException {
  KeyUnavailableException(String message) : super(message);
}

class CorruptRecordException extends VaultException {
  CorruptRecordException(String message) : super(message);
}

class TamperedRecordException extends VaultException {
  TamperedRecordException(String message) : super(message);
}

class UserVaultSecurityService {
  final VaultCipher _cipher;
  final Lock _lock = Lock();

  UserVaultSecurityService({VaultCipher? cipher})
      : _cipher = cipher ?? AndroidKeystoreVaultCipher();

  Future<String> secureRecord(String plaintext, String id) async {
    if (plaintext.isEmpty) throw VaultException('Cannot secure empty record');

    return _lock.synchronized(() async {
      try {
        final ciphertext = await _cipher.encrypt(plaintext, id);
        return jsonEncode({
          'version': 1,
          'id': id,
          'data': ciphertext,
        });
      } catch (e) {
        throw KeyUnavailableException('Failed to encrypt record: $e');
      }
    });
  }

  Future<String> recoverRecord(String payload, String expectedId) async {
    return _lock.synchronized(() async {
      String ciphertext = payload;

      try {
        final envelope = jsonDecode(payload);
        if (envelope is Map<String, dynamic> && envelope.containsKey('version')) {
          if (envelope['version'] != 1) {
            throw VaultException('Unsupported envelope version');
          }
          if (envelope['id'] != expectedId) {
            throw TamperedRecordException('Record ID mismatch (tampering detected)');
          }
          ciphertext = envelope['data'] as String;
        }
      } catch (e) {
        if (e is TamperedRecordException || e is VaultException) {
          rethrow;
        }
        // If JSON parsing fails (FormatException), we assume it's a legacy raw ciphertext and continue
      }

      try {
        return await _cipher.decrypt(ciphertext, expectedId);
      } catch (e) {
        if (e is VaultException) rethrow;
        final errStr = e.toString().toLowerCase();

        if (errStr.contains('corrupt') || errStr.contains('invalid format') || errStr.contains('padding') || errStr.contains('mismatch')) {
          throw CorruptRecordException('Failed to decrypt record (corrupted): $e');
        }

        throw KeyUnavailableException('Failed to decrypt record: $e');
      }
    });
  }
}
