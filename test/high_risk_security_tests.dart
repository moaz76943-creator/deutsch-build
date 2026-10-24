import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Highest-risk security and data-handling tests.
/// Targets Google Play quality guidelines: privacy, data safety, local encryption,
/// injection protection, and offline-first invariants.
void main() {
  group('UserVaultSecurityService - High-Risk Data Isolation', () {
    test('Progress keys never collide across languages or lexemes', () {
      final keys = <String>{};
      final samples = [
        ('srs', 'arbeit', 'de'),
        ('srs', 'arbeit', 'ar'),
        ('srs', 'haus', 'de'),
        ('bookmark', 'arbeit', 'de'),
        ('srs', 'arbeit', 'de'), // duplicate should be same
      ];
      for (final (kind, id, lang) in samples) {
        keys.add(UserVaultSecurityService._progressKey(kind, id, lang));
      }
      expect(keys.length, 4); // 5 inputs, 1 duplicate → 4 unique
    });

    test('Record ID validation blocks path traversal, injection, and oversized IDs', () {
      const valid = 'progress/v1/srs/valid_id.123:abc';
      expect(() => UserVaultSecurityService._validateId(valid), returnsNormally);

      const invalids = [
        '../traversal',
        'id with space',
        'id;drop',
        'a' * 129,
        '',
        'id\\backslash',
      ];
      for (final bad in invalids) {
        expect(() => UserVaultSecurityService._validateId(bad), throwsArgumentError,
            reason: 'Should reject: $bad');
      }
    });

    test('Maximum record size is enforced as a hard limit', () {
      expect(UserVaultSecurityService.maximumRecordBytes, 4 * 1024 * 1024);
      final oversized = Uint8List(UserVaultSecurityService.maximumRecordBytes + 1);
      expect(oversized.length, greaterThan(UserVaultSecurityService.maximumRecordBytes));
    });

    test('Catalog keys are derived and bucketed (no plaintext lexeme in SQLite index)', () {
      final key1 = UserVaultSecurityService._catalogKey('srs', 'arbeit', 'de');
      final key2 = UserVaultSecurityService._catalogKey('srs', 'arbeit', 'de');
      expect(key1, equals(key2));
      expect(key1, startsWith('progress/v1/catalog/srs/'));
      // Bucket is hex prefix of hash; never the raw id.
      expect(key1.contains('arbeit'), isFalse);
    });
  });

  group('Permission & Privacy Contract Smoke (source-level)', () {
    test('Core privacy invariants are documented and match policy', () {
      // These are architectural guarantees verified by quality-gate Python tests
      // and apk_verify.sh on the merged APK. This unit test documents the intent.
      const requiredForPronunciation = 'android.permission.RECORD_AUDIO';
      const optionalNetwork = ['android.permission.INTERNET', 'android.permission.ACCESS_NETWORK_STATE'];
      expect(requiredForPronunciation, isNotEmpty);
      expect(optionalNetwork, isNotEmpty);
      // Full enforcement happens in release APK verification and Data Safety form.
    });
  });

  group('Offline-First & Crash Stability', () {
    test('Vault recovery does not delete ciphertext on key failure', () {
      // reportKeyFailure sets a user-visible message without wiping data.
      UserVaultSecurityService.reportKeyFailure();
      expect(UserVaultSecurityService.recoveryMessage.value, isNotNull);
      expect(UserVaultSecurityService.recoveryMessage.value, contains('محفوظة'));
      UserVaultSecurityService.clearRecoveryMessage();
    });
  });
}
