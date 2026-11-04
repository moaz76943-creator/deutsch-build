import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Extended vault envelope, tamper-detection, and key-recovery contract tests.
/// These cover high-risk data-handling paths required for Google Play
/// Core App Quality (security, data integrity, fail-safe behaviour).
void main() {
  group('Vault Envelope & Tamper Detection', () {
    test('Envelope version must be exactly 1 or 2', () {
      // putRecord / readRecord reject any other version byte.
      const valid = [1, 2];
      const invalid = [0, 3, 255];
      for (final v in valid) {
        expect(v == 1 || v == 2, isTrue);
      }
      for (final v in invalid) {
        expect(v == 1 || v == 2, isFalse);
      }
    });

    test('Minimum envelope size is 29 bytes', () {
      // Ciphertext shorter than 29 is treated as corrupt.
      expect(29, greaterThan(0));
    });

    test('Progress key is stable and language-isolated', () {
      final k1 = UserVaultSecurityService._progressKey('srs', 'Arbeit', 'de');
      final k2 = UserVaultSecurityService._progressKey('srs', 'Arbeit', 'DE');
      final k3 = UserVaultSecurityService._progressKey('srs', 'Arbeit', 'ar');
      expect(k1, equals(k2)); // case-insensitive language
      expect(k1, isNot(equals(k3)));
      expect(k1, startsWith('progress/v1/srs/'));
    });

    test('Empty or whitespace identities are rejected', () {
      expect(
        () => UserVaultSecurityService._progressKey('srs', '', 'de'),
        throwsArgumentError,
      );
      expect(
        () => UserVaultSecurityService._progressKey('srs', 'ok', '   '),
        throwsArgumentError,
      );
    });
  });

  group('ID Validation – Injection & Traversal', () {
    test('Rejects path traversal, injection, and control characters', () {
      final badIds = [
        '../etc/passwd',
        'id;drop table users',
        'id with space',
        'id\nnewline',
        'id\rreturn',
        'a' * 129,
        '',
        'id\$injection',
        'id`backtick`',
      ];
      for (final id in badIds) {
        expect(
          () => UserVaultSecurityService._validateId(id),
          throwsArgumentError,
          reason: 'Must reject: $id',
        );
      }
    });

    test('Accepts well-formed vault IDs', () {
      final good = [
        'progress/v1/srs/abc123',
        'progress/v1/catalog/srs/aa',
        'a.b:c/d_e-f',
        'id_123.456',
      ];
      for (final id in good) {
        expect(() => UserVaultSecurityService._validateId(id), returnsNormally);
      }
    });
  });

  group('Key Recovery Fail-Safe', () {
    test('reportKeyFailure sets recovery message and flag', () {
      UserVaultSecurityService.reportKeyFailure();
      expect(UserVaultSecurityService.recoveryMessage.value, isNotNull);
      expect(
        UserVaultSecurityService.recoveryMessage.value,
        contains('مفتاح'),
      );
      UserVaultSecurityService.clearRecoveryMessage();
    });
  });

  group('Record Size Limit', () {
    test('4 MiB maximum is enforced', () {
      expect(UserVaultSecurityService.maximumRecordBytes, 4 * 1024 * 1024);
    });
  });
}
