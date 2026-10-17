import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';
import 'dart:convert';

class MockVaultCipher implements VaultCipher {
  bool forceEncryptFailure = false;
  bool forceDecryptFailure = false;
  bool forceCorruptCiphertext = false;

  @override
  Future<String> encrypt(String plaintext, String id) async {
    if (forceEncryptFailure) throw Exception('Mock encryption failure');
    final ciphertext = 'ENCRYPTED($plaintext)-$id';
    return forceCorruptCiphertext ? 'CORRUPT' : ciphertext;
  }

  @override
  Future<String> decrypt(String ciphertext, String id) async {
    if (forceDecryptFailure) throw Exception('Mock decryption failure');
    if (!ciphertext.endsWith('-$id')) {
      throw Exception('Mock decryption failed: ID mismatch');
    }
    const prefix = 'ENCRYPTED(';
    final suffix = ')-$id';
    if (ciphertext.startsWith(prefix) && ciphertext.endsWith(suffix)) {
      return ciphertext.substring(prefix.length, ciphertext.length - suffix.length);
    }
    throw Exception('Mock decryption failed: Invalid format');
  }
}

void main() {
  group('UserVaultSecurityService', () {
    late UserVaultSecurityService service;
    late MockVaultCipher mockCipher;

    setUp(() {
      mockCipher = MockVaultCipher();
      service = UserVaultSecurityService(cipher: mockCipher);
    });

    test('secureRecord encrypts and packages correctly', () async {
      final envelopeStr = await service.secureRecord('secret data', 'user123');
      final envelope = jsonDecode(envelopeStr);

      expect(envelope['version'], 1);
      expect(envelope['id'], 'user123');
      expect(envelope['data'], 'ENCRYPTED(secret data)-user123');
    });

    test('recoverRecord decrypts valid envelope', () async {
      final envelopeStr = await service.secureRecord('secret data', 'user123');
      final recovered = await service.recoverRecord(envelopeStr, 'user123');

      expect(recovered, 'secret data');
    });

    test('recoverRecord rejects ID mismatch (tampering)', () async {
      final envelopeStr = await service.secureRecord('secret data', 'user123');

      // Attempt to recover with different expected ID
      expect(
        () => service.recoverRecord(envelopeStr, 'user456'),
        throwsA(isA<TamperedRecordException>()),
      );
    });

    test('recoverRecord rejects tampered envelope ID', () async {
      final envelopeStr = await service.secureRecord('secret data', 'user123');
      final envelope = jsonDecode(envelopeStr);

      // Tamper with envelope ID
      envelope['id'] = 'user456';
      final tamperedStr = jsonEncode(envelope);

      expect(
        () => service.recoverRecord(tamperedStr, 'user456'),
        throwsA(isA<CorruptRecordException>()), // In mock, native ID fails because the suffix is -user123 and expected is -user456. So it reports as a corrupt record.
      );
    });

    test('secureRecord throws on encryption failure', () async {
      mockCipher.forceEncryptFailure = true;
      expect(
        () => service.secureRecord('secret data', 'user123'),
        throwsA(isA<KeyUnavailableException>()),
      );
    });

    test('recoverRecord throws KeyUnavailableException on generic decryption failure', () async {
      final envelopeStr = await service.secureRecord('secret data', 'user123');
      mockCipher.forceDecryptFailure = true;

      expect(
        () => service.recoverRecord(envelopeStr, 'user123'),
        throwsA(isA<KeyUnavailableException>()),
      );
    });

    test('recoverRecord falls back to legacy raw ciphertext when not JSON', () async {
      final rawCiphertext = await mockCipher.encrypt('legacy secret', 'old_user');
      final recovered = await service.recoverRecord(rawCiphertext, 'old_user');

      expect(recovered, 'legacy secret');
    });

    test('recoverRecord rejects unsupported version', () async {
      final envelopeStr = jsonEncode({
        'version': 2,
        'id': 'user123',
        'data': 'ENCRYPTED(secret data)-user123',
      });
      expect(
        () => service.recoverRecord(envelopeStr, 'user123'),
        throwsA(isA<VaultException>().having((e) => e.message, 'message', contains('Unsupported envelope version'))),
      );
    });

    test('concurrent operations are protected', () async {
      // Create multiple concurrent secure/recover operations
      final futures = <Future>[];
      for (var i = 0; i < 10; i++) {
        futures.add(service.secureRecord('data $i', 'user$i').then((envelope) {
          return service.recoverRecord(envelope, 'user$i');
        }));
      }

      final results = await Future.wait(futures);
      for (var i = 0; i < 10; i++) {
        expect(results[i], 'data $i');
      }
    });

    test('secureRecord rejects empty plaintext', () async {
      expect(
        () => service.secureRecord('', 'user123'),
        throwsA(isA<VaultException>().having((e) => e.message, 'message', contains('Cannot secure empty record'))),
      );
    });

    test('recoverRecord fails on corrupt record state', () async {
      mockCipher.forceCorruptCiphertext = true;
      final envelopeStr = await service.secureRecord('secret data', 'user123');
      mockCipher.forceCorruptCiphertext = false;

      expect(
        () => service.recoverRecord(envelopeStr, 'user123'),
        throwsA(isA<CorruptRecordException>()),
      );
    });
  });
}
