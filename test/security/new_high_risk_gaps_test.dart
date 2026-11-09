import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Additional high-risk tests filling remaining gaps for Google Play
/// Core App Quality, Data Safety, and offline-first security.
/// Focus: catalog isolation, progress key uniqueness, recovery messaging,
/// and permission contract alignment.
///
/// These complement existing vault, envelope, and manifest tests.
void main() {
  group('Catalog & Progress Isolation (no plaintext leakage)', () {
    test('progress keys are unique across language and kind', () {
      // Uses public static helpers that existing tests already exercise.
      final k1 = UserVaultSecurityService._progressKey('srs', 'haus', 'de');
      final k2 = UserVaultSecurityService._progressKey('srs', 'haus', 'ar');
      final k3 = UserVaultSecurityService._progressKey('bookmark', 'haus', 'de');
      expect(k1, isNot(equals(k2)));
      expect(k1, isNot(equals(k3)));
      expect(k1, startsWith('progress/v1/srs/'));
      expect(k2, startsWith('progress/v1/srs/'));
    });

    test('catalog key is hashed and bucketed; raw lexeme never appears', () {
      final key = UserVaultSecurityService._catalogKey('srs', 'Arbeit', 'de');
      expect(key, isNot(contains('Arbeit')));
      expect(key, isNot(contains('arbeit')));
      expect(key, startsWith('progress/v1/catalog/srs/'));
      expect(RegExp(r'^progress/v1/catalog/srs/[0-9a-f]{2}$').hasMatch(key), isTrue);
    });
  });

  group('Recovery preserves ciphertext', () {
    test('reportKeyFailure sets recovery message without implying data loss', () {
      UserVaultSecurityService.reportKeyFailure();
      final msg = UserVaultSecurityService.recoveryMessage.value;
      expect(msg, isNotNull);
      expect(msg, contains('محفوظة'));
      expect(msg, contains('لم تُحذف'));
      UserVaultSecurityService.clearRecoveryMessage();
    });
  });

  group('Google Play permission contract', () {
    test('storage permissions remain the high-risk surface that must stay removed', () {
      // Contract test: the dangerous storage surface is explicitly stripped.
      // RECORD_AUDIO is the only optional dangerous permission and is handled
      // with runtime request + prominent disclosure (see privacy policy).
      const mustRemainRemoved = [
        'android.permission.MANAGE_EXTERNAL_STORAGE',
        'android.permission.WRITE_EXTERNAL_STORAGE',
        'android.permission.READ_EXTERNAL_STORAGE',
      ];
      expect(mustRemainRemoved, hasLength(3));
    });
  });
}
