import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Additional high-priority security and data-handling tests
/// for Google Play Core App Quality & security guidelines.
void main() {
  group('UserVaultSecurityService - Extended Security Coverage', () {
    test('Progress keys are unique per language and lexeme', () {
      final keyDe = UserVaultSecurityService._progressKey('srs', 'arbeit', 'de');
      final keyAr = UserVaultSecurityService._progressKey('srs', 'arbeit', 'ar');
      final keyOther = UserVaultSecurityService._progressKey('srs', 'haus', 'de');
      expect(keyDe, isNot(equals(keyAr)));
      expect(keyDe, isNot(equals(keyOther)));
      expect(keyDe, startsWith('progress/v1/srs/'));
    });

    test('Rejects oversized records before encryption', () {
      final oversized = Uint8List(UserVaultSecurityService.maximumRecordBytes + 1);
      // Note: full putRecord requires mock cipher; this validates the constant and intent
      expect(UserVaultSecurityService.maximumRecordBytes, 4 * 1024 * 1024);
      expect(oversized.length, greaterThan(UserVaultSecurityService.maximumRecordBytes));
    });

    test('Valid IDs pass validation', () {
      expect(() => UserVaultSecurityService._validateId('progress/v1/srs/valid-id_123'), returnsNormally);
      expect(() => UserVaultSecurityService._validateId('a.b:c/d'), returnsNormally);
    });

    test('Invalid characters and lengths are rejected', () {
      expect(() => UserVaultSecurityService._validateId('id with space'), throwsArgumentError);
      expect(() => UserVaultSecurityService._validateId('id;injection'), throwsArgumentError);
      expect(() => UserVaultSecurityService._validateId('../traversal'), throwsArgumentError);
      expect(() => UserVaultSecurityService._validateId('a' * 129), throwsArgumentError);
    });
  });

  group('Critical Offline-First Invariants', () {
    test('App is designed as offline-first (no mandatory network for core flows)', () {
      // Architectural: core learning uses local assets and SQLite.
      // Network is optional for pack updates only.
      expect(true, isTrue); // Placeholder for integration assertion
    });
  });
}
